import 'package:flutter/material.dart';
class GlobalDD{
  static final List<String> jobCategoryList = [
    'On-site',
    'Hybrid',
    'Remote'

  ];

  static final List<String> academicLists = [
    'Primary School',
    'Secondary School',
    'College',
    'Diploma',
    'Bachelor',
    'Master',
    'Phd.',
    'Not Required',
  ];
  static final List<String> jobTypeList = [
    'Permanent Role',
    'Internship',
    'Part Time',
    'Freelance','Contract', 'Temporary', 'Volunteer','Other'
  ];
 static final List<String> countries = ['Malaysia', 'United States', 'India'];

  static final List<String> categories = const [
    'Web Design', 'Mobile Design', 'Fashion Design', 'Packaging Design',
    'Advertising Design', 'Graphic Design', 'Interior Design', 'Architecture Design',
    'Logo Design', 'Animation Design'
  ];

 static final Map<String, List<String>> states = {
    'Malaysia': ['Selangor', 'Penang', 'Johor', 'Sarawak'],
    'United States': ['California', 'Texas', 'New York', 'Florida'],
    'India': ['Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu'],
  };

  static final List<String> positions = [
    'Student',
    'UI Designer',
    'UX Designer',
    'Product Designer',
    'Graphic Designer',
    'Freelancer',
    'Frontend Developer',
    'Backend Developer',
    'Project Manager',
    'Other',
  ];

  static final List<String> designCategoryList = [
    'Web Design',
    'Illustration',
    'Animation',
    'Branding',
    'Print',
    'Product Design',
    'Mobile',
    'Typography'
  ];

}
