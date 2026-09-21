import { Controller, Post, UseInterceptors, UploadedFile, UseGuards } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UploadService } from './upload.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { diskStorage } from 'multer';
import { extname } from 'path';

@UseGuards(JwtAuthGuard)
@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('profile-photo')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${file.fieldname}-${uniqueSuffix}${extname(file.originalname)}`);
      }
    })
  }))
  uploadProfilePhoto(@UploadedFile() file: Express.Multer.File) {
    return { url: `/uploads/${file.filename}` };
  }

  @Post('document')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${file.fieldname}-${uniqueSuffix}${extname(file.originalname)}`);
      }
    })
  }))
  uploadDocument(@UploadedFile() file: Express.Multer.File) {
    return { url: `/uploads/${file.filename}` };
  }
}
