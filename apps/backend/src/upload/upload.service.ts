import { Injectable, Logger } from '@nestjs/common';
import { v2 as cloudinary } from 'cloudinary';
import { Readable } from 'stream';

@Injectable()
export class UploadService {
  private readonly logger = new Logger(UploadService.name);

  constructor() {
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
      secure: true,
    });
  }

  /**
   * Upload a file buffer to Cloudinary.
   * Returns the secure HTTPS URL of the uploaded file.
   */
  async uploadFile(
    buffer: Buffer,
    originalname: string,
    folder: string = 'chintamani',
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
      const publicId = `${folder}/${uniqueSuffix}`;

      const uploadStream = cloudinary.uploader.upload_stream(
        {
          public_id: publicId,
          resource_type: 'auto',
          overwrite: true,
          // For images: auto quality + format
          transformation: folder === 'chintamani/photos'
            ? [{ width: 800, crop: 'limit', quality: 'auto', fetch_format: 'auto' }]
            : undefined,
        },
        (error, result) => {
          if (error) {
            this.logger.error(`Cloudinary upload failed: ${error.message}`);
            return reject(new Error(`File upload failed: ${error.message}`));
          }
          resolve(result!.secure_url);
        },
      );

      const readable = new Readable();
      readable.push(buffer);
      readable.push(null);
      readable.pipe(uploadStream);
    });
  }

  /**
   * Delete a file from Cloudinary by URL.
   */
  async deleteFile(url: string): Promise<void> {
    try {
      // Extract public_id from Cloudinary URL
      const parts = url.split('/upload/');
      if (parts.length !== 2) return;
      const withVersion = parts[1];
      // Remove version prefix (v12345678/) if present
      const publicIdWithExt = withVersion.replace(/^v\d+\//, '');
      // Remove extension
      const publicId = publicIdWithExt.replace(/\.[^/.]+$/, '');
      await cloudinary.uploader.destroy(publicId);
    } catch (e) {
      this.logger.warn(`Could not delete Cloudinary file: ${url}`);
    }
  }
}
