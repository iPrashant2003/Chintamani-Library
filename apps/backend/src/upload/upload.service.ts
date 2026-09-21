import { Injectable } from '@nestjs/common';

@Injectable()
export class UploadService {
  // Logic mostly handled in controller via Multer for local storage.
  // We can add S3/GCS integrations here in future if needed.
}
