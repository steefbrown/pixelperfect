using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Drawing;

namespace ImageConverter
{
    class Converter
    {
        private const int width = 640;
        private const int height = 480;

        public static Bitmap convertTo8Bit(Bitmap original)
        {
            Bitmap converted = new Bitmap(original, width, height);

            for (int x = 0; x < width; x++)
            {
                for (int y = 0; y < height; y++)
                {
                    Color oldColor = converted.GetPixel(x, y);
                    Color newColor = Color.FromArgb(oldColor.R & 0xE0, oldColor.G & 0xE0, oldColor.B & 0xC0);
                    converted.SetPixel(x, y, newColor);
                }
            }

            return converted;
        }

        public static void saveBinaryFile(FileStream stream, params Bitmap[] images)
        {
            using (BinaryWriter writer = new BinaryWriter(stream))
            {
                foreach (Bitmap image in images)
                {
                    Bitmap converted = new Bitmap(image, width, height);

                    for (int x = 0; x < height; x++)
                    {
                        for (int y = 0; y < width; y++)
                        {
                            Color oldColor = converted.GetPixel(y, x);
                            int red = (oldColor.R & 0xE0);
                            int green = (oldColor.G & 0xE0) >> 3;
                            int blue = (oldColor.B & 0xC0) >> 6;
                            int color = red | green | blue;
                            writer.Write((byte)color);
                        }
                    }
                }

                writer.Close();
            }
        }

        public static Bitmap decodeBinaryFile(FileStream stream)
        {
            Bitmap decoded = new Bitmap(width, height);

            using (BinaryReader reader = new BinaryReader(stream))
            {
                for (int x = 0; x < height; x++)
                {
                    for (int y = 0; y < width; y++)
                    {
                        int color = reader.ReadByte();
                        int red = color & 0xE0;
                        int green = (color & 0x1C) << 3;
                        int blue = (color & 0x03) << 6;
                        Color c = Color.FromArgb(red, green, blue);
                        decoded.SetPixel(y, x, c);
                    }
                }

                reader.Close();
            }

            return decoded;
        }
    }
}
