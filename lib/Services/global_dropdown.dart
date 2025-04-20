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

 static final Map<String, List<String>> states = {
    'Malaysia': ['Selangor', 'Penang', 'Johor', 'Sarawak'],
    'United States': ['California', 'Texas', 'New York', 'Florida'],
    'India': ['Maharashtra', 'Karnataka', 'Delhi', 'Tamil Nadu'],
  };


}