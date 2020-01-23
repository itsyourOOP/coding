using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WindowsFormsApplication1
{
    
    public partial class Form1 : Form
    {
        string nl = VbX.Chr(13) + VbX.Chr(10);
        int step = 4;
        int Frequency = 0;
        int FileLength = 0;
        int Bitdepth = 4;
        string DestFile = "";
        public Form1()
        {
            InitializeComponent();
            txtInfo.Text = "This program will read 44100hz 16 bit signed Mono wave file, " + "And will output a 1/2/4 bit packed (multiple samples per byte) RAW PCM file, it also allows downsampling";
        }
        private void button1_Click(object sender, EventArgs e)
        {
            if (cboBitDepth.Text == "CPC+ DMA") {
                DoCPCPLUS4Bit();
                return;
            }

            DoNBitPacked(Bitdepth);
            
            /*
            switch (Bitdepth)
            {
                case 8:
                    Do8Bit();
                    break;
                case 4:
                    Do4BitPacked();
                    break;
                case 2:
                    Do2BitPacked();
                    break;
                case 1:
                    Do1BitPacked();
                    break;
            }
             */
        }

        private void DoCPCPLUS4Bit()
        {
            byte lastsample=255;
            int sampcount = 0;      // thanks to Roudoudou for advise on adding loops to reduce file size
            double[] left;
            double[] right;
            openWav(txtSrc.Text, out left, out right);
            System.IO.BinaryWriter BW = new System.IO.BinaryWriter(System.IO.File.Open(DestFile, System.IO.FileMode.Create));
            BW.Write((byte)(61));
            BW.Write((byte)(7));
            for (int pos = 0; pos < left.Length - step; pos += step)
            {

                byte b = 0;
                int thisd = 0;
                for (int i = 0; i < step; i++)
                {
                    thisd += (int)(left[pos + i] * 32768);
                }
                thisd = thisd / step;

                b = (byte)((thisd / 256) + 128);
                b = (byte)(b / 16);
                // VbX.MsgBox(left[pos].ToString() + " " + b.ToString());
                

                if (b != lastsample)
                {
                    lastsample = b;
                    if (sampcount > 0)
                    {
                        BW.Write((byte)(sampcount % 255));
                        BW.Write((byte)(((sampcount / 255) % 16) + 16));
                    }
                    BW.Write(b);
                    BW.Write((byte)(9));

                    sampcount = 0;
                }
                else {
                    sampcount++;
                    if (sampcount == 4095)
                    {
                        BW.Write((byte)(sampcount % 255));
                        BW.Write((byte)(((sampcount / 255) % 16) + 16));
                        sampcount = 0;
                    }
                }
                
            }
            BW.Write((byte)(63));
            BW.Write((byte)(7));
            BW.Close();
        }
        private void DoNBitPacked(int bits)
        {
            int dividor = 1;
            int multiplyer = 1;
            switch (bits) {
                case 1:
                    dividor = 128;
                    multiplyer = 2;
                    break;
                case 2:
                    dividor = 64;
                    multiplyer = 4;
                    break;
                case 4:
                    dividor = 16;
                    multiplyer = 16;
                    break;
            
            
            }

            double[] left;
            double[] right;
            openWav(txtSrc.Text, out left, out right);
            System.IO.BinaryWriter BW = new System.IO.BinaryWriter(System.IO.File.Open(DestFile, System.IO.FileMode.Create));

            byte b2 = 0;
            int packed = 0;
            for (int pos = 0; pos <= left.Length - step; pos += step)
            {

                byte b = 0;
                int thisd = 0;
                for (int i = 0; i < step; i++)
                {
                    thisd += (int)(left[pos + i] * 32768);
                }
                thisd = thisd / step;



                b = (byte)((thisd / 256) + 128);
                if (chkUseLUT.Checked)
                {
                    b2 = (byte)(b2 + GetFromLUT(b,bits,dividor));
                }
                else
                {
                    b2 = (byte)(b2 + (b / dividor));
                }

                //b = (byte)(Math.Abs(thisd / 256)*2);
                
                ;
                // VbX.MsgBox(left[pos].ToString() + " " + b.ToString());
                packed++;
                if (packed == (8/bits))
                {
                    packed = 0;
                    BW.Write(b2);
                    b2 = 0;
                }
                else
                {
                    b2 = (byte)(b2 * multiplyer);
                }

            }
            BW.Close();
        }
        static byte GetFromLUT(byte b,int bits,int dividor){// The values used here are those used by Gasman in his Spectrum demos.
            switch (bits){ 
                case 4:
                    if (b <= 1) return 0;
                    if (b <= 4) return 1;
                    if (b <= 6) return 2;
                    if (b <= 9) return 3;
                    if (b <= 13) return 4;
                    if (b <= 18) return 5;
                    if (b <= 28) return 6;
                    if (b <= 39) return 7;
                    if (b <= 54) return 8;
                    if (b <= 79) return 9;
                    if (b <= 102) return 10;
                    if (b <= 130) return 11;
                    if (b <= 160) return 12;
                    if (b <= 196) return 13;
                    if (b <= 235) return 14;
                    return 15;
            
            
        case 2:
                    if (b <= 1) return 0;
                    if (b <= 4) return 0;
                    if (b <= 6) return 0;
                    if (b <= 9) return 0;
                    if (b <= 13) return 1;
                    if (b <= 18) return 1;
                    if (b <= 28) return 1;
                    if (b <= 39) return 1;
                    if (b <= 54) return 2;
                    if (b <= 79) return 2;
                    if (b <= 102) return 2;
                    if (b <= 130) return 2;
                    if (b <= 160) return 3;
                    if (b <= 196) return 3;
                    if (b <= 235) return 3;
                    return 3;
            }
            return (byte)(b / dividor);
            
        }
        // convert two bytes to one double in the range -1 to 1
        static double bytesToDouble(short firstByte, short secondByte)
        {
            // convert two bytes to one short (little endian)
            short s = (short)((secondByte * 256) + firstByte);// *256;
                
                //+firstByte);
            // convert to range from -1 to (just below) 1
            return s / 32768.0;
        }

        // Returns left and right double arrays. 'right' will be null if sound is mono.
        public void GetWavInfo(string filename) {
            byte[] wav = System.IO.File.ReadAllBytes(filename);
            Frequency=wav[24] + wav[24 + 1] * 256 + wav[24 + 2] * 65536 + wav[24 + 3] * 16777216;
            int channels = wav[22];     // Forget byte 23 as 99.999% of WAVs are 1 or 2 channels
            FileLength = ((wav.Length - 44) / 2) / channels;
        }
        
        public void openWav(string filename, out double[] left, out double[] right)
        {
            byte[] wav = System.IO.File.ReadAllBytes(filename);

            // Determine if mono or stereo
            int channels = wav[22];     // Forget byte 23 as 99.999% of WAVs are 1 or 2 channels
            // Frequency = wav[24] + wav[24 + 1] * 256 + wav[24 + 2] * 65536 + wav[24 + 3] * 16777216;
            
            // Get past all the other sub chunks to get to the data subchunk:
            int pos = 12;   // First Subchunk ID from 12 to 16

            // Keep iterating until we find the data chunk (i.e. 64 61 74 61 ...... (i.e. 100 97 116 97 in decimal))
            while (!(wav[pos] == 100 && wav[pos + 1] == 97 && wav[pos + 2] == 116 && wav[pos + 3] == 97))
            {
                pos += 4;
                int chunkSize = wav[pos] + wav[pos + 1] * 256 + wav[pos + 2] * 65536 + wav[pos + 3] * 16777216;
                pos += 4 + chunkSize;
            }
            pos += 8;
            long length = wav.Length;
            // Pos is now positioned to start of actual sound data.
            int samples = (wav.Length - pos) / 2;     // 2 bytes per sample (16 bit sound mono)
            if (channels == 2) samples /= 2;        // 4 bytes per sample (16 bit stereo)

            // Allocate memory (right will be null if only mono sound)
            left = new double[samples];
            if (channels == 2) right = new double[samples];
            else right = null;

            // Write to double array/s:
            int i = 0;
            while (pos < length - 1 && i < samples)
            {
                left[i] = bytesToDouble(wav[pos], wav[pos + 1]);
              //  VbX.MsgBox(wav[pos].ToString() + wav[pos+1].ToString()+" "+" "+left[i].ToString());
                pos += 2;
                if (channels == 2)
                {
                    right[i] = bytesToDouble(wav[pos], wav[pos + 1]);
                    pos += 2;
                }
                i++;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            OpenFileDialog fd = new OpenFileDialog();
            fd.Filter = "Wave file (*.wav)|*.wav";
            DialogResult dr = fd.ShowDialog();
            if (dr == DialogResult.OK) txtSrc.Text = fd.FileName;
            GetWavInfo(txtSrc.Text);
            
            updateinfo();

        }
        private void updateinfo() {
            
            txtInfo.Text = "";
            step = VbX.CInt(txtScale.Text);
            if (step == 0) step = 1;


            txtInfo.Text += "Input  Frequency   :" + Frequency.ToString()+nl;
            txtInfo.Text += "Filelength         :" + FileLength.ToString() + nl;
            
            Bitdepth = VbX.CInt(VbX.Left(cboBitDepth.Text,1));


            if (cboBitDepth.Text == "CPC+ DMA") { Bitdepth = 16; }
            Single dividor = 8 / Bitdepth;
            if (dividor<=0) dividor=1;
            //if (cboBitDepth.Text == "CPC+ DMA") { dividor = 0.5F; }
            txtInfo.Text += "Output Frequency   :" + (Frequency / step).ToString() + nl;
            txtInfo.Text += "Output Size (bytes):" + ((FileLength / step) / dividor).ToString() + nl;
            DestFile = txtSrc.Text.ToLower().Replace(".wav", Bitdepth.ToString() + "-" + step.ToString() + ".raw");
        }

        private void txtScale_TextChanged(object sender, EventArgs e)
        {
            
            updateinfo();
        }

        private void cboBitDepth_KeyPress(object sender, KeyPressEventArgs e)
        {
            e.Handled = true;
        }

        private void cboBitDepth_TextChanged(object sender, EventArgs e)
        {
            if (cboBitDepth.Text == "CPC+ DMA") txtScale.Text = "3";
            updateinfo();
        }

        private void cboBitDepth_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

    }
}
/*
The canonical WAVE format starts with the RIFF header:

0         4   ChunkID          Contains the letters "RIFF" in ASCII form
                               (0x52494646 big-endian form).
4         4   ChunkSize        36 + SubChunk2Size, or more precisely:
                               4 + (8 + SubChunk1Size) + (8 + SubChunk2Size)
                               This is the size of the rest of the chunk 
                               following this number.  This is the size of the 
                               entire file in bytes minus 8 bytes for the
                               two fields not included in this count:
                               ChunkID and ChunkSize.
8         4   Format           Contains the letters "WAVE"
                               (0x57415645 big-endian form).

The "WAVE" format consists of two subchunks: "fmt " and "data":
The "fmt " subchunk describes the sound data's format:

12        4   Subchunk1ID      Contains the letters "fmt "
                               (0x666d7420 big-endian form).
16        4   Subchunk1Size    16 for PCM.  This is the size of the
                               rest of the Subchunk which follows this number.
20        2   AudioFormat      PCM = 1 (i.e. Linear quantization)
                               Values other than 1 indicate some 
                               form of compression.
22        2   NumChannels      Mono = 1, Stereo = 2, etc.
24        4   SampleRate       8000, 44100, etc.
28        4   ByteRate         == SampleRate * NumChannels * BitsPerSample/8
32        2   BlockAlign       == NumChannels * BitsPerSample/8
                               The number of bytes for one sample including
                               all channels. I wonder what happens when
                               this number isn't an integer?
34        2   BitsPerSample    8 bits = 8, 16 bits = 16, etc.
          2   ExtraParamSize   if PCM, then doesn't exist
          X   ExtraParams      space for extra parameters

The "data" subchunk contains the size of the data and the actual sound:

36        4   Subchunk2ID      Contains the letters "data"
                               (0x64617461 big-endian form).
40        4   Subchunk2Size    == NumSamples * NumChannels * BitsPerSample/8
                               This is the number of bytes in the data.
                               You can also think of this as the size
                               of the read of the subchunk following this 
                               number.
44        *   Data             The actual sound data.
*/