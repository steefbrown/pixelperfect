using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.IO;
using System.Drawing.Imaging;

namespace MainController
{
    class Converter
    {
        private const int width = 640;
        private const int height = 480;

        // convert image to 8-bit version
        public static byte[] to8bit(Image image)
        {
            Bitmap converted = new Bitmap(image, width, height);
            byte[] bytes = new byte[width * height];
            int bytecount = 0;

            for (int x = 0; x < height; x++)
            {
                for (int y = 0; y < width; y++)
                {
                    Color oldColor = converted.GetPixel(y, x);
                    int red = (oldColor.R & 0xE0);
                    int green = (oldColor.G & 0xE0) >> 3;
                    int blue = (oldColor.B & 0xC0) >> 6;
                    int color = red | green | blue;

                    bytes[bytecount] = (byte)color;
                    bytecount++;
                }
            }

            return bytes;
        }

        // convert imageData to jpeg and save to outputFileName
        public static void decodeBinaryFile(byte[] imageData, string outputFileName)
        {
            Bitmap decoded = new Bitmap(width, height);

            int byteCount = 0;

            for (int x = 0; x < height; x++)
            {
                for (int y = 0; y < width; y++)
                {
                    int color = imageData[byteCount++];
                    int red = color & 0xE0;
                    int green = (color & 0x1C) << 3;
                    int blue = (color & 0x03) << 6;
                    Color c = Color.FromArgb(red, green, blue);
                    decoded.SetPixel(y, x, c);
                }
            }

            SaveJPG100(decoded, outputFileName);
        }

        private static void SaveJPG100(Bitmap bmp, string filename)
        {
            Stream stream = new FileStream(filename, FileMode.OpenOrCreate);
            EncoderParameters encoderParameters = new EncoderParameters(1);
            encoderParameters.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 100L);

            ImageCodecInfo[] codecs = ImageCodecInfo.GetImageDecoders();
            bmp.Save(stream, GetEncoder(ImageFormat.Jpeg), encoderParameters);
            stream.Close();
        }

        private static ImageCodecInfo GetEncoder(ImageFormat format)
        {
            ImageCodecInfo[] codecs = ImageCodecInfo.GetImageDecoders();
            return codecs.Single(codec => codec.FormatID == format.Guid);
        }
    }
}
