using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace CustomControlLibrary
{
    // http://stackoverflow.com/questions/1827323/c-synchronize-scroll-position-of-two-richtextboxes
    // http://stackoverflow.com/questions/3322741/synchronizing-multiline-textbox-positions-in-c-sharp
    public class SynchronizedScrollRichTextBox : System.Windows.Forms.RichTextBox
    {
        public const int WM_VSCROLL = 0x115;
        public const int WM_MOUSEWHEEL = 0x020A;

        List<SynchronizedScrollRichTextBox> peers = new List<SynchronizedScrollRichTextBox>();

        public void DirectWndProc(ref System.Windows.Forms.Message msg)
        {
            base.WndProc(ref msg);
        }

        public void AddPeer(SynchronizedScrollRichTextBox peer)
        {
            this.peers.Add(peer);
        }

        protected override void WndProc(ref Message m)
        {
            // http://stackoverflow.com/questions/3593099/richtextbox-disabling-mouse-scrolling
            if (m.Msg == WM_MOUSEWHEEL)
                return;

            if (m.Msg == WM_VSCROLL)
            {
                foreach (var peer in this.peers)
                {
                    var peerMessage = Message.Create(peer.Handle, m.Msg, m.WParam, m.LParam);
                    peer.DirectWndProc(ref peerMessage);
                }
            }

            base.WndProc(ref m);
        }
    }
}
