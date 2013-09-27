using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Assembler
{
    class FileLine
    {
        public int lineNum;
        public string hexInst;
        public string originalInst;
        public Boolean isInstruction;

        public FileLine(int _lineNum, string _hexInst, string _originalInst, Boolean _isInstruction)
        {
            this.lineNum = _lineNum;
            this.hexInst = _hexInst;
            this.originalInst = _originalInst;
            this.isInstruction = _isInstruction;
        }
    }
}
