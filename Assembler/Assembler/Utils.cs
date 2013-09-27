using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Assembler
{
    class Utils
    {
        // breaks a string into tokens based on either comma or spaces (or both)
        // without returning empty tokens
        public static string[] Tokenize(string line)
        {
            return Regex.Split(line, @"[,\s*]").Where(s => !string.IsNullOrEmpty(s)).ToArray();
        }
    }
}
