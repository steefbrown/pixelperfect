using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

namespace Assembler
{
    public delegate void WriteCompleteEventHandler();

    // Supports writing to .dat and .coe
    class HexInstWriter
    {
        public event WriteCompleteEventHandler FireWriteComplete;

        private const int RamSize = 8192; // number of 32-bit words

        // writes out each instruction to .dat file
        public void WriteDAT(string coeFileName, ArrayList assembledLines)
        {
            ArrayList hexInstructions = extractHexInstructions(assembledLines);
            System.IO.StreamWriter datFile = new System.IO.StreamWriter(coeFileName);
            for (int i = 0; i < hexInstructions.Count; i++)
                datFile.WriteLine(hexInstructions[i]);
            for (int i = hexInstructions.Count; i < RamSize; i++)
                datFile.WriteLine("00000000"); // pad in zeroes
            datFile.Close();

            if (FireWriteComplete != null)
                FireWriteComplete();
        }

        // writes out each instruction to .coe file
        public void WriteCOE(string coeFileName, ArrayList assembledLines)
        {
            ArrayList hexInstructions = extractHexInstructions(assembledLines);
            System.IO.StreamWriter coeFile = new System.IO.StreamWriter(coeFileName);
            coeFile.WriteLine("memory_initialization_radix=16;");
            coeFile.WriteLine("memory_initialization_vector=");
            for (int i = 0; i < hexInstructions.Count - 1; i++)
                coeFile.WriteLine(hexInstructions[i] + ",");
            coeFile.WriteLine(hexInstructions[hexInstructions.Count - 1] + ";");
            coeFile.Close();

            if (FireWriteComplete != null)
                FireWriteComplete();
        }

        private ArrayList extractHexInstructions(ArrayList assembledLines)
        {
            ArrayList hexInsructions = new ArrayList();
            foreach (FileLine line in assembledLines)
                if (line.isInstruction)
                    hexInsructions.Add(line.hexInst);
            return hexInsructions;
        }
    }
}
