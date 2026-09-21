import { Injectable } from '@nestjs/common';
import PDFDocument from 'pdfkit';

@Injectable()
export class PdfService {
  async generateMembersReport(members: any[]): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ margin: 50 });
      const buffers: Buffer[] = [];

      doc.on('data', (buffer) => buffers.push(buffer));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', (err) => reject(err));

      // Header
      doc.fontSize(20).text('Chintamani Library', { align: 'center' });
      doc.fontSize(12).text('Members Report', { align: 'center' });
      doc.moveDown(2);

      // Table Header
      doc.fontSize(10).font('Helvetica-Bold');
      doc.text('Code', 50, doc.y, { continued: true });
      doc.text('Name', 120, doc.y, { continued: true });
      doc.text('Phone', 300, doc.y, { continued: true });
      doc.text('Status', 420, doc.y);
      doc.moveDown(0.5);

      // Table Rows
      doc.font('Helvetica');
      members.forEach((member) => {
        doc.text(member.memberCode || 'N/A', 50, doc.y, { continued: true });
        doc.text(member.name, 120, doc.y, { continued: true });
        doc.text(member.phone, 300, doc.y, { continued: true });
        doc.text(member.isActive ? 'Active' : 'Inactive', 420, doc.y);
        doc.moveDown(0.5);
      });

      doc.end();
    });
  }
}
