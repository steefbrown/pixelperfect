using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

namespace Assembler
{
    class Pseudo
    {
        // Takes the original instruction, which may or may not be a 
        // pseudo instruction, and adds the resulting instructions to newLines.
        // Returns true if line was a pseudo.
        public static bool Decompose(string line, ArrayList newLines)
        {
            int lineCount = newLines.Count;
            string[] tokens = Utils.Tokenize(line);

            try
            {
                if (tokens.Length > 0)
                {
                    // Here is where we can define any pseudo instructions that we want
                    // and what they break down into.
                    //
                    // The general strategy is:
                    //      - Add a comment for the original instruction
                    //      - Add each of the instructions you want to call
                    //
                    // Notice that pseudo instructions can be composed of other pseudos
                    // just as long as they don't cause circular dependencies ;)
                    switch (tokens[0].ToLower())
                    {
                        case "call":
                            newLines.Add("\t// call " + tokens[1]);
                            newLines.Add("\t\tpush $pc");
                            newLines.Add("\t\tpush $bp");
                            newLines.Add("\t\tmov $sp, $bp");
                            newLines.Add("\t\tbuc " + tokens[1]);  // branch unconditionally to label
                            break;
                        case "ret":
                            newLines.Add("\t// ret");
                            newLines.Add("\t\tmov $bp, $sp");
                            newLines.Add("\t\tpop $bp");
                            newLines.Add("\t\tpop $r12");
                            newLines.Add("\t\taddi 15, $r12"); // increment recovered pc by 15
                            newLines.Add("\t\tjuc $r12"); // jump to pc
                            break;
                        case "push":
                            newLines.Add("\t// push " + tokens[1]);
                            newLines.Add("\t\tsubi 2, $sp"); // move stack pointer down
                            newLines.Add("\t\tstord " + tokens[1] + ", $sp");
                            break;
                        case "pop":       
                            newLines.Add("\t// pop " + tokens[1]);
                            newLines.Add("\t\tloadd " + tokens[1] + ", $sp");
                            newLines.Add("\t\taddi 2, $sp");
                            break;
                        case "stord": // store 32bit word
                            newLines.Add("\t// stord " + tokens[1] + ", " + tokens[2]);
                            newLines.Add("\t\tstor " + tokens[1] + ", " + tokens[2]);
                            newLines.Add("\t\tmov " + tokens[1] + ", $r12");
                            newLines.Add("\t\tsrli 16, $r12");
                            newLines.Add("\t\tmov " + tokens[2] + ", $r11");
                            newLines.Add("\t\taddi 1, $r11");
                            newLines.Add("\t\tstor $r12, $r11");
                            break;
                        case "loadd": // load 32bit word
                            newLines.Add("\t// loadd " + tokens[1] + ", " + tokens[2]);
                            newLines.Add("\t\tmov " + tokens[2] + ", $r11");
                            newLines.Add("\t\taddi 1, $r11");
                            newLines.Add("\t\tload " + tokens[1] + ", $r11");
                            newLines.Add("\t\tslli 16, " + tokens[1]);
                            newLines.Add("\t\tload $r10, " + tokens[2]);
                            newLines.Add("\t\tor $r10, " + tokens[1]);
                            break;

                        // case "yourPseudoInstructionHere" ...
                    }
                }
            }
            catch (Exception e)
            {
                throw new ArgumentException("Check pseudo instruction \"" + line + "\" (" + e.Message + ")");
            }

            if (lineCount != newLines.Count) 
            {
                // if instructions where added, return true
                return true;    
            }
            else
            {
                // otherwise just add the original line and return false
                newLines.Add(line);
                return false;
            }
        }
    }
}
