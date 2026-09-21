import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';

export class RegisterTenantDto {
  @ApiProperty({ example: 'Apex Reading Lounge' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'ARL' })
  @IsString()
  @IsNotEmpty()
  code: string;

  @ApiProperty({ example: 'Rajesh Sharma' })
  @IsString()
  @IsNotEmpty()
  ownerName: string;

  @ApiProperty({ example: 'owner@apexreading.com' })
  @IsEmail()
  ownerEmail: string;

  @ApiProperty({ example: 'Password@123' })
  @IsString()
  @MinLength(6)
  ownerPassword: string;

  @ApiProperty({ example: '9876543210', required: false })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ example: 'Gorakhpur', required: false })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiProperty({ example: 'Uttar Pradesh', required: false })
  @IsString()
  @IsOptional()
  state?: string;

  @ApiProperty({ example: 'Civil Lines', required: false })
  @IsString()
  @IsOptional()
  address?: string;
}
