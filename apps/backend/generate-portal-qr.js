const QRCode = require('qrcode');
const fs = require('fs');
const path = require('path');

async function generateQrs() {
  const portalUrl = 'https://chintamani-library.in/portal/index.html';

  const publicQrDir = path.join(__dirname, 'public', 'qr');
  if (!fs.existsSync(publicQrDir)) {
    fs.mkdirSync(publicQrDir, { recursive: true });
  }

  const publicPath = path.join(publicQrDir, 'universal-portal-qr.png');
  const rootPath = path.join(__dirname, '..', '..', 'Chintamani-Library-Universal-Portal-QR.png');

  // Generate high-resolution printable QR code
  await QRCode.toFile(publicPath, portalUrl, {
    width: 800,
    margin: 2,
    color: {
      dark: '#111827',
      light: '#ffffff',
    },
    errorCorrectionLevel: 'H',
  });

  await QRCode.toFile(rootPath, portalUrl, {
    width: 1000,
    margin: 2,
    color: {
      dark: '#111827',
      light: '#ffffff',
    },
    errorCorrectionLevel: 'H',
  });

  console.log(`Generated Universal Portal QR at: ${publicPath}`);
  console.log(`Generated Printable Root QR at: ${rootPath}`);
}

generateQrs().catch(console.error);
