import 'package:equatable/equatable.dart';

class DlKycEntity extends Equatable {
  final bool isAadharVerified;
  final String? gender;
  final String? maskedAadhaar;
  final String? dob;
  final String? dateTime;

  final String? aadharFilename;
  final String? aadharImgFilename;
  final String? adharImg;

  final String? aadharAddress;
  final String? aadharNo;
  // final String? aadharXml;

  final String? fatherName;
  final String? name;

  // final String? panNumber;
  // final String? nameOnPan;

  const DlKycEntity({
    this.isAadharVerified = false,
    this.gender,
    this.maskedAadhaar,
    this.dob,
    this.dateTime,
    this.aadharFilename,
    this.aadharImgFilename,
    this.adharImg,
    this.aadharAddress,
    this.aadharNo,
    // this.aadharXml,
    this.fatherName,
    this.name,
    // this.panNumber,
    // this.nameOnPan,
  });

  @override
  List<Object?> get props => [
    isAadharVerified,
    gender,
    maskedAadhaar,
    dob,
    dateTime,
    aadharFilename,
    aadharImgFilename,
    adharImg,
    aadharAddress,
    aadharNo,
    // aadharXml,
    fatherName,
    name,
    // panNumber,
    // nameOnPan,
  ];
}
