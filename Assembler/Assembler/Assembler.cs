using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections;

namespace Assembler
{
    public delegate void AssemblyCompleteEventHandler(ArrayList assembledLines, int numHexInstructions, bool success);
    public delegate void ErrorEventHandler(string message);
    public delegate void StatusUpdateEventHandler(string message);

    //
    // Custom assembler for our custom ISA (loosely based on CR16 ISA)
    // 
    // CS3710 PixelPerfect
    // Fall 2012
    //
    class Assembler
    {
        public event AssemblyCompleteEventHandler FireAssemblyComplete;
        public event ErrorEventHandler FireError;
        public event StatusUpdateEventHandler FireStatusUpdate;

        private int lineNumber;                         
        private ArrayList lines;                        // holds all the lines of the file
        private Dictionary<int, string[]> instTokens;   // map of instruction address to tokens for instruction
        private Dictionary<string, int> labels;         // map of string labels to instruction address
        private int instAddress;                        // keeps track of current instruction address
        private ArrayList assembledLines;               // holds the resulting hex instructions
        private HashSet<int> instLines;                 // the line numbers that are instructions
        private int numHexInstructions;
        private bool success;

        public void Build(string asmFileName)
        {
            success = false;

            try
            {
                // STAGE 1
                lines = new ArrayList();
                System.IO.StreamReader asmFile = new System.IO.StreamReader(asmFileName);
                string curLine;
                // Put each line into the list
                if (FireStatusUpdate != null) FireStatusUpdate("Reading " + asmFileName + "...");
                while ((curLine = asmFile.ReadLine()) != null)
                {
                    lines.Add(curLine);
                }
                asmFile.Close();
            }
            catch (Exception e)
            {
                if (FireError != null) FireError("Failed to read file! " + e.Message);
                return;
            }

            try
            {
                // STAGE 2
                // repeatedly decompose any pseudo instructions until they're all gone!
                bool done = false;
                int round = 1;
                while (!done)
                {
                    ArrayList newLines = new ArrayList();
                    done = true;

                    if (FireStatusUpdate != null) FireStatusUpdate("Decomposing pseudos, round " + round);

                    foreach (string line in lines)
                    {
                        bool changesMade = Pseudo.Decompose(line, newLines);
                        if (changesMade)
                            done = false;
                    }

                    lines = newLines;
                    round++;
                }
            }
            catch (Exception e)
            {
                if (FireError != null) FireError("Failed to decompose pseudo instructions! " + e.Message);
                return;
            }

            try
            {
                // STAGE 3
                instTokens = new Dictionary<int, string[]>();
                labels = new Dictionary<string, int>();
                instLines = new HashSet<int>();
                lineNumber = instAddress = 0;

                // Map out label addresses
                if (FireStatusUpdate != null) FireStatusUpdate("Mapping labels to addresses...");
                foreach (string line in lines)
                {
                    FindLabelsAndInstructions(line);
                    lineNumber++;
                }
            }
            catch (Exception e)
            {
                if (FireError != null) FireError("Failed tokenize instructions! Line " + lineNumber + ": " + e.Message);
                return;
            }

            try
            {
                // STAGE 4
                numHexInstructions = 0;
                lineNumber = instAddress = 0;
                assembledLines = new ArrayList();
                // Go over each line and build each instruction
                if (FireStatusUpdate != null) FireStatusUpdate("Encoding instructions to hex...");
                foreach (string line in lines)
                {
                    string nextHexLine = instLines.Contains(lineNumber) ? ParseLine(line) : String.Empty;

                    bool isInstruction = !string.IsNullOrEmpty(nextHexLine);
                    assembledLines.Add(new FileLine(lineNumber, nextHexLine, line, isInstruction));

                    lineNumber++;
                    if (isInstruction)
                        numHexInstructions++;
                }

                success = true;
            }
            catch (Exception e)
            {
                assembledLines.Add(new FileLine(lineNumber, "????", (string)lines[lineNumber], true));
                if (FireError != null) FireError("Failed to decode instruction! Line " + lineNumber + ": " + e.Message);
            }


            if (FireAssemblyComplete != null)
            {
                // Send off to gui thread
                FireAssemblyComplete(assembledLines, numHexInstructions, success);
            }
        }

        private void FindLabelsAndInstructions(string line)
        {
            string[] tokens = Utils.Tokenize(line);

            if (tokens.Length > 0)
            {
                // assume labels are aligned to the left of the file (no leading spaces)
                if (!line.StartsWith(" ") && !line.StartsWith("\t") && !line.StartsWith("/"))
                {
                    // Not an empty line or an instruction or a comment => must be a label
                    string label = tokens[0];

                    if (label.EndsWith(":")) // remove the ':', if present
                        label = label.Substring(0, label.Length - 1);

                    labels.Add(label, instAddress);
                }
                else if (!tokens[0].StartsWith("/"))
                {
                    // must be an instruction
                    instLines.Add(lineNumber);
                    instTokens.Add(instAddress, tokens);
                    instAddress++;
                }
            }
        }

        // pulls the next instruction out of the map based on instAddress
        private string ParseLine(string line)
        {
            string[] tokens;
            instTokens.TryGetValue(instAddress, out tokens);
            string hexInstruction = ParseTokens(tokens);
            instAddress++;
            return hexInstruction;
        }

        private string ParseTokens(string[] tokens)
        {
            // in general:
            //      tokens[0] = op
            //      tokens[1] = first operand (rSrc/Imm)
            //      tokens[2] = second operand (rDst)

            switch (tokens[0].ToLower())
            {
//Boolean Ops
                case "and":
                    return BuildRTypeInst("1", tokens);
                case "andi":
                    return BuildITypeInst("1", tokens);
                case "or":
                    return BuildRTypeInst("2", tokens);
                case "ori":
                    return BuildITypeInst("2", tokens);
                case "xor":
                    return BuildRTypeInst("3", tokens);
                case "xori":
                    return BuildITypeInst("3", tokens);
//Addition       
                case "add":
                    return BuildRTypeInst("5", tokens);
                case "addi":
                    return BuildITypeInst("5", tokens);
                case "addu":
                    return BuildRTypeInst("6", tokens);
                case "addui":
                    return BuildITypeInst("6", tokens);
//Shifts
                case "sll":
                    return BuildSTypeInst("1", tokens);
                case "slli":
                    return BuildSTypeImmInst("9", tokens);
                case "srl":
                    return BuildSTypeInst("2", tokens);
                case "srli":
                    return BuildSTypeImmInst("A", tokens);
                case "sra":
                    return BuildSTypeInst("3", tokens);
                case "srai":
                    return BuildSTypeImmInst("B", tokens);
//Subtraction
                case "sub":
                    return BuildRTypeInst("9", tokens);
                case "subi":
                    return BuildITypeInst("9", tokens);
//Compares
                case "cmp":
                    return BuildRTypeInst("B", tokens);
                case "cmpi":
                    return BuildITypeInst("B", tokens);
// Branches
                case "beq":
                    return BuildBCondInst("0", tokens);
                case "bge":
                    return BuildBCondInst("6", tokens);
                case "bgt":
                    return BuildBCondInst("3", tokens);
                case "bne":
                    return BuildBCondInst("8", tokens);
                case "blt":
                    return BuildBCondInst("E", tokens);
                case "ble":
                    return BuildBCondInst("B", tokens);
                case "buc": // branch unconditionally
                    return BuildBCondInst("7", tokens);
//Set Conditional
                case "seq":
                    return BuildSCondInst("0", tokens);
                case "sge":
                    return BuildSCondInst("6", tokens);
                case "sne":
                    return BuildSCondInst("8", tokens);
                case "slt":
                    return BuildSCondInst("E", tokens);
//Jumps
                case "jeq":
                    return BuildJCondInst("0", tokens);
                case "jge":
                    return BuildJCondInst("6", tokens);
                case "jne":
                    return BuildJCondInst("8", tokens);
                case "jlt":
                    return BuildJCondInst("D", tokens);
                case "juc":
                    return BuildJCondInst("7", tokens);
                case "jal": // Jump And Link
                    return BuildOTypeInst("8", tokens);
//Memory
                case "load":
                    return BuildOTypeInst("0", tokens);
                case "stor":
                    return BuildOTypeInst("4", tokens);
//Moves
                case "mov":
                    return BuildRTypeInst("D", tokens);
                case "movi":
                    return BuildITypeInst("D", tokens);
//Multiply
                case "mul":
                    return BuildRTypeInst("E", tokens);
                case "muli":
                    return BuildITypeInst("E", tokens);
                case "lui":
                    return BuildITypeInst("F", tokens);
                default:
                    throw new ArgumentException("Unrecognized Op \"" + tokens[0] + "\"");
            }
        }

        // ITYPE
        private string BuildITypeInst(string opCode, string[] tokens)
        {
            return opCode + GetRegHex(tokens[2]) + GetImmHex(tokens[1], 6);
        }
        // RTYPE
        private string BuildRTypeInst(string extOpCode, string[] tokens)
        {
            return "0" + GetRegHex(tokens[2]) + extOpCode + GetRegHex(tokens[1]) + "0000";
        }
        // STYPE (shifts)
        private string BuildSTypeInst(string extOpCode, string[] tokens)
        {
            return "8" + GetRegHex(tokens[2]) + extOpCode + GetRegHex(tokens[1]) + "0000";
        }
        // STYPE with Immediate
        private string BuildSTypeImmInst(string extOpCode, string[] tokens)
        {
            return "8" + GetRegHex(tokens[2]) + extOpCode + GetImmHex(tokens[1], 5);
        }
        // Bcond
        private string BuildBCondInst(string condCode, string[] tokens)
        {
            return "C" + condCode + GetImmHex(CalcBranchDisp(tokens[1]), 6);
        }
        // Jcond
        private string BuildJCondInst(string condCode, string[] tokens)
        {
            return "4" + condCode + "C" + GetRegHex(tokens[1]) + "0000";
        }
        // Scond
        private string BuildSCondInst(string condCode, string[] tokens)
        {
            return "4" + GetRegHex(tokens[1]) + "D" + condCode + "0000";
        }
        // OTYPE (others)
        private string BuildOTypeInst(string extOpCode, string[] tokens)
        {
            // notice how src and dst are switched
            // not true for all OTYPE, but others are covered by Jcond and Scond
            return "4" + GetRegHex(tokens[1]) + extOpCode + GetRegHex(tokens[2]) + "0000";
        }

        private int GetLabelAddress(string label)
        {
            int labelAddr;
            bool found = labels.TryGetValue(label, out labelAddr);
            if (!found)
                throw new InvalidDataException("Could not find address of \"" + label + "\"");
            return labelAddr;
        }

        private int CalcBranchDisp(string label)
        {
            return GetLabelAddress(label) - instAddress;
        }

        private string GetRegHex(string reg)
        {
            try
            {                
                int regVal = 0;
                if (reg == "$pc")
                    regVal = 15;
                else if (reg == "$bp")
                    regVal = 14;
                else if (reg == "$sp")
                    regVal = 13;
                else // remove "$r"
                    regVal = int.Parse(reg.Substring(2));
                // return 4-bit hex version
                return regVal.ToString("X1");
            }
            catch
            {
                throw new InvalidDataException("Could not parse register named \"" + reg + "\"");
            }
        }

        private string GetImmHex(string immediate, int hexDigits)
        {
            int intValue;

            try
            {
                if (immediate.StartsWith("0x"))
                {
                    // assume it's a properly formatted hex string
                    intValue = int.Parse(immediate.Substring(2), System.Globalization.NumberStyles.HexNumber);
                }
                else
                {
                    // assume it's a decimal number
                    intValue = int.Parse(immediate);
                }
            }
            catch
            {
                throw new InvalidDataException("Could not parse immediate \"" + immediate + "\"");
            }

            // hack check of immediate
            if (intValue < -8388608 || intValue > 16777216)
            {
                throw new InvalidDataException("Immediate is too large! \"" + immediate + "\"");
            }

            return GetImmHex(intValue, hexDigits);
        }

        private string GetImmHex(int intValue, int hexDigits)
        {
            string hexVal = intValue.ToString("X"+hexDigits);

            // it seems that ToString(XL) will only guarantee that is is at LEAST L long, so use substring
            return hexVal.Substring(hexVal.Length - hexDigits, hexDigits);
        }
    }
}
