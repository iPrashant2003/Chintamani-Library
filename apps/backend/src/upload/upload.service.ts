import { Injectable, Logger } from '@nestjs/common';
import { v2 as cloudinary } from 'cloudinary';
import { Readable } from 'stream';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class UploadService {
  private readonly logger = new Logger(UploadService.name);
  private readonly hasCloudinary: boolean;
  private readonly storageRoot: string;

  constructor() {
    const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
    const apiKey = process.env.CLOUDINARY_API_KEY;
    const apiSecret = process.env.CLOUDINARY_API_SECRET;

    if (cloudName && apiKey && apiSecret && cloudName.trim() !== '') {
      cloudinary.config({
        cloud_name: cloudName.trim(),
        api_key: apiKey.trim(),
        api_secret: apiSecret.trim(),
        secure: true,
      });
      this.hasCloudinary = true;
      this.logger.log(`[UploadService] Cloudinary configured for cloud: ${cloudName}`);
    } else {
      this.hasCloudinary = false;
      this.logger.log('[UploadService] Cloudinary credentials not provided. Using reliable local disk storage.');
    }

    this.storageRoot = path.resolve(process.cwd(), process.env.STORAGE_PATH || './uploads');
    if (!fs.existsSync(this.storageRoot)) {
      fs.mkdirSync(this.storageRoot, { recursive: true });
    }
  }

  /**
   * Save a file buffer to persistent local disk storage.
   * Returns a publicly accessible web path starting with /uploads/...
   */
  private async saveToLocalDisk(
    buffer: Buffer,
    originalname: string,
    folder: string,
  ): Promise<string> {
    const cleanFolder = folder.replace(/^[\/\\]+|[\/\\]+$/g, '').replace(/\\/g, '/');
    const targetDir = path.join(this.storageRoot, cleanFolder);
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true });
    }

    const ext = path.extname(originalname) || '.jpg';
    const baseName = path.basename(originalname, ext).replace(/[^a-zA-Z0-9_-]/g, '_');
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const filename = `${baseName}_${uniqueSuffix}${ext}`;
    const filePath = path.join(targetDir, filename);

    await fs.promises.writeFile(filePath, buffer);
    this.logger.log(`[UploadService] File saved to disk: ${filePath} (${buffer.length} bytes)`);

    // Return URL path served by Express static assets
    return `/uploads/${cleanFolder}/${filename}`;
  }

  /**
   * Upload a file buffer to Cloudinary or fallback to persistent local storage.
   * Returns accessible URL of the uploaded file.
   */
  async uploadFile(
    buffer: Buffer,
    originalname: string,
    folder: string = 'chintamani',
  ): Promise<string> {
    if (!buffer || buffer.length === 0) {
      throw new Error('Upload buffer is empty');
    }

    // If Cloudinary is available, attempt cloud upload first
    if (this.hasCloudinary) {
      try {
        const cloudUrl = await new Promise<string>((resolve, reject) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          const publicId = `${folder}/${uniqueSuffix}`;

          const uploadStream = cloudinary.uploader.upload_stream(
            {
              public_id: publicId,
              resource_type: 'auto',
              overwrite: true,
              transformation: folder.includes('photos')
                ? [{ width: 1200, crop: 'limit', quality: 'auto', fetch_format: 'auto' }]
                : undefined,
            },
            (error, result) => {
              if (error) {
                return reject(error);
              }
              if (result && result.secure_url) {
                resolve(result.secure_url);
              } else {
                reject(new Error('Cloudinary response missing secure_url'));
              }
            },
          );

          const readable = new Readable();
          readable.push(buffer);
          readable.push(null);
          readable.pipe(uploadStream);
        });

        this.logger.log(`[UploadService] Cloudinary upload successful: ${cloudUrl}`);
        return cloudUrl;
      } catch (cloudErr: any) {
        this.logger.warn(`[UploadService] Cloudinary upload failed (${cloudErr.message}). Seamlessly falling back to local persistent storage.`);
      }
    }

    // Fallback or Primary: Save reliably to persistent local disk
    return this.saveToLocalDisk(buffer, originalname, folder);
  }

  /**
   * Delete a file by URL (Cloudinary or local disk).
   */
  async deleteFile(url: string): Promise<void> {
    try {
      if (!url) return;

      if (url.startsWith('/uploads/')) {
        const relPath = url.replace(/^\/uploads\//, '');
        const fullPath = path.join(this.storageRoot, relPath);
        if (fs.existsSync(fullPath)) {
          await fs.promises.unlink(fullPath);
          this.logger.log(`[UploadService] Deleted local file: ${fullPath}`);
        }
        return;
      }

      if (this.hasCloudinary && url.includes('cloudinary.com')) {
        const parts = url.split('/upload/');
        if (parts.length === 2) {
          const withVersion = parts[1];
          const publicIdWithExt = withVersion.replace(/^v\d+\//, '');
          const publicId = publicIdWithExt.replace(/\.[^/.]+$/, '');
          await cloudinary.uploader.destroy(publicId);
          this.logger.log(`[UploadService] Deleted Cloudinary file: ${publicId}`);
        }
      }
    } catch (e: any) {
      this.logger.warn(`[UploadService] Could not delete file: ${url} - ${e.message}`);
    }
  }
}
