import { IsNotEmpty, IsString, IsOptional, IsNumber, IsEmail } from 'class-validator';

export class SendOtpDto {
  @IsString()
  @IsNotEmpty()
  phone!: string;
}

export class VerifyOtpDto {
  @IsString()
  @IsNotEmpty()
  phone!: string;

  @IsString()
  @IsNotEmpty()
  otp!: string;
}

export class PortalRegisterDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsNotEmpty()
  phone!: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  dob?: string;

  @IsOptional()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  aadhaarNumber?: string;

  @IsOptional()
  @IsString()
  emergencyContact?: string;

  @IsOptional()
  @IsString()
  batch?: string;

  @IsOptional()
  @IsString()
  course?: string;

  @IsOptional()
  @IsString()
  institute?: string;

  @IsOptional()
  @IsString()
  occupation?: string;

  @IsOptional()
  @IsString()
  photoUrl?: string;

  @IsOptional()
  @IsString()
  aadhaarFrontUrl?: string;

  @IsOptional()
  @IsString()
  aadhaarBackUrl?: string;

  @IsOptional()
  @IsString()
  otherDocUrls?: string;

  @IsString()
  @IsNotEmpty()
  planId!: string;

  @IsOptional()
  @IsString()
  branchId?: string;

  @IsOptional()
  @IsString()
  branch?: string;

  @IsOptional()
  @IsString()
  seatNumber?: string;

  @IsOptional()
  @IsString()
  seatId?: string;
}

export class PortalPaymentDto {
  @IsOptional()
  @IsString()
  memberId?: string;

  @IsString()
  @IsNotEmpty()
  memberPhone!: string;

  @IsOptional()
  @IsString()
  memberName?: string;

  @IsNumber()
  amount!: number;

  @IsString()
  @IsNotEmpty()
  paymentType!: string; // MEMBERSHIP, MAINTENANCE, RENEWAL, OTHER

  @IsOptional()
  @IsString()
  screenshotUrl?: string;

  @IsOptional()
  @IsString()
  txnRef?: string;

  @IsOptional()
  @IsString()
  upiId?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  branchId?: string;
}

export class PortalComplaintDto {
  @IsString()
  @IsNotEmpty()
  memberPhone!: string;

  @IsString()
  @IsNotEmpty()
  memberName!: string;

  @IsOptional()
  @IsString()
  memberId?: string;

  @IsOptional()
  @IsString()
  branchId?: string;

  @IsString()
  @IsNotEmpty()
  category!: string; // AC, ELECTRICITY, SEAT, CLEANLINESS, INTERNET, OTHER

  @IsString()
  @IsNotEmpty()
  description!: string;

  @IsOptional()
  @IsString()
  attachmentUrls?: string;
}

export class PortalFeedbackDto {
  @IsString()
  @IsNotEmpty()
  memberName!: string;

  @IsOptional()
  @IsString()
  memberPhone?: string;

  @IsNumber()
  rating!: number; // 1 to 5

  @IsString()
  @IsNotEmpty()
  category!: string; // LIBRARY, STAFF, SEATING, CLEANLINESS, FACILITIES, TIMING, OVERALL

  @IsString()
  @IsNotEmpty()
  review!: string;

  @IsOptional()
  @IsString()
  branchId?: string;

  @IsOptional()
  @IsString()
  memberId?: string;
}

export class PortalAttendanceDto {
  @IsString()
  @IsNotEmpty()
  identifier!: string; // Mobile number or Member Code (e.g., CML-942810)

  @IsOptional()
  @IsString()
  branchId?: string;
}

