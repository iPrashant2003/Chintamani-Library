import { IsString, IsEmail, IsOptional, IsArray, IsEnum } from 'class-validator';

enum Role {
  OWNER = 'OWNER',
  ADMIN = 'ADMIN',
  STAFF = 'STAFF'
}

export class CreateUserDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  password?: string; // Using optional for simplicity in this example

  @IsEnum(Role)
  role: Role;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  branchIds?: string[];
}
