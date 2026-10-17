import { IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ChangePasswordDto {
  @ApiPropertyOptional({ example: '9415919277 or owner@chintamani.com' })
  @IsOptional()
  @IsString()
  identifier?: string;

  @ApiProperty({ example: 'CurrentPassword123' })
  @IsString()
  @IsNotEmpty()
  oldPassword!: string;

  @ApiProperty({ example: 'NewSecretPassword123' })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  newPassword!: string;
}
