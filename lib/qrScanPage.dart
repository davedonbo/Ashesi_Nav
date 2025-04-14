import 'package:ashesi_nav/Models/landMark.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'data.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({Key? key}) : super(key: key);
  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _scanning = false;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  String qrResult = '';
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  void _toggleScan() {
    setState(() {
      _scanning = !_scanning;
    });
  }
  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if(scanData.code == qrResult) return;
        qrResult = scanData.code ?? '';
        print("qr content here: ${qrResult}");

        if(qrResult.contains("ashesinav/")){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ashesi Nav location detected'),
              backgroundColor: Colors.black,
            ),
          );

          for(LandMark lm in Data.landMarks){
            String cmp = qrResult.substring(10).toLowerCase().trim();
            if(lm.ref?.toLowerCase()== cmp){
              Navigator.pop(context,lm);
              break;
            }

          }


        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This qr is not related to Ashesi Nav'),
              backgroundColor: Colors.black,
            ),
          );
        }
      });
    });
  }
  Widget _buildQrView() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color(0xffa93c3f),
        borderRadius: 8,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 250,
      ),
    );
  }
  Widget _buildCenterContent() {
    return _scanning ? _buildQrView() : Image.asset(
      'images/qr.png',
      fit: BoxFit.cover,
      height: 200,
      width: 200,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffa93c3f),
      body: Column(
        children: [
          Expanded(
            child: Center(child: _buildCenterContent()),
          ),
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Find your way quickly!',
                    style: GoogleFonts.ubuntu(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan a QR code to get directions to your location',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _toggleScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffa93c3f),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Scan QR code',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
