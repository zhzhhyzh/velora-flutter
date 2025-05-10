import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:velora2/Widgets/the_app_bar.dart';

import '../Services/email_sender.dart';

class OfferDesignerScreen extends StatefulWidget {
  final DocumentSnapshot designer;

  const OfferDesignerScreen({super.key, required this.designer});

  @override
  State<OfferDesignerScreen> createState() => _OfferDesignerScreenState();
}

class _OfferDesignerScreenState extends State<OfferDesignerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _rateCtrl = TextEditingController();
  DateTime? sDate;
  Timestamp? sDateTimestamp;
  DateTime? eDate;
  Timestamp? eDateTimestamp;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.designer.data() as Map<String,dynamic>;

    final String countryCode;
    if (data['country'] == 'Malaysia') {
      countryCode = 'ms_My';
    } else if (data['country'] == 'India') {
      countryCode = 'en_IN';
    } else {
      countryCode = 'en_US';
    }

    final _currencyFormatter = intl.NumberFormat('#,##0.00', countryCode);


    return Scaffold(
      appBar: TheAppBar(content: 'Offer ${data['name']}', style: 2,),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
                children: [
                  CircleAvatar(
                    backgroundImage: MemoryImage(base64Decode(data['profileImg'])),
                    radius: 50,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? 'Designer Name',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,height: 1.25),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                              color: Colors.green.shade100,
                              child: Center(
                                child: Text(
                                  data['category'] ?? 'Designer Category',
                                  style:TextStyle(fontSize: 13,color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                    style: const TextStyle(fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: 'Contact No.: ',
                                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
                                      ),
                                      TextSpan(
                                          text: (data['contact'] ?? '').toString().trim().isNotEmpty
                                              ? data['contact']
                                              : null,
                                          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black)
                                      )
                                    ]
                                ),
                              ),
                              RichText(
                                maxLines: 2,
                                text: TextSpan(
                                    style: const TextStyle(fontSize: 14),
                                    children: [
                                      TextSpan(
                                        text: 'Email: ',
                                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),
                                      ),
                                      TextSpan(
                                        text: (data['email'] ?? '').toString().trim().isNotEmpty
                                            ? data['email']
                                            : null,
                                        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),

                                      )
                                    ]
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                  ),
                ]
            ),
            const Divider(height: 30, thickness: 1),
            Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textTitle(label: 'Project Description:'),
                    _textFormField(
                        controller: _descCtrl,
                        hintText: 'Describe your project requirements',
                        maxLength: 1000,
                        multiline: true
                    ),

                    _textTitle(label: 'Start Date (dd/mm/yyyy):'),
                    _textFormFieldDate(
                        valueKey: 'Start',
                        controller: _startDateCtrl,
                        enabled: false,
                        fct: () {_pickStartDateDialog();},
                        hint: 'Select Project Start Date'
                    ),

                    _textTitle(label: 'End Date (dd/mm/yyyy):'),
                    _textFormFieldDate(
                        valueKey: 'End',
                        controller: _endDateCtrl,
                        enabled: false,
                        fct: () {_pickEndDateDialog();},
                        hint: 'Select Project End Date'
                    ),

                    _textTitle(label: 'Offer Rate:'),
                    _textFormField(
                        controller: _rateCtrl,
                        hintText: ' Enter amount',
                        maxLength: 10,
                        hideCounter: true,
                        prefix: Text(_currencyFormatter.currencySymbol),
                        keyboardType: TextInputType.number
                    ),
                  ],
                )
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _isSubmitting
                    ?  null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                        context: context,
                        builder: (context) =>
                        AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Offer Confirmation"),
                          content:  Text(
                              "Are you sure you want to offer the job for ${data['name']} ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel", style: TextStyle(color: Colors.red),),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF689f77),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _submitOffer();
                              },
                              child: const Text("Confirm",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                    );
                  }
                },

              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF689f77),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
              ),
              child:
              _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'SUBMIT',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final designerData = widget.designer.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.collection('offers').add({
        // 'offerId' : ,
        'recruiterEmail': user!.email,
        // 'recruiterName': user!.name,
        'recruiterPhone': user!.phoneNumber,
        'projectStartTime' :_startDateCtrl.text,
        'projectEndTime' : _endDateCtrl.text,
        'projectDesc' : _descCtrl.text,
        'offerRate' : _rateCtrl.text,
        'offerTo' : designerData['name'],
        'designerEmail' : designerData['email'],
        'designerPhone' : designerData['contact']
      });
      final emailSender = EmailSender();

      final designerEmail = designerData['email'];

      try {
        await emailSender.sendEmail(
          toEmail: designerEmail,
          toName: 'Designer',
          // subject: 'New Offer from ${user.name}',
          htmlContent: '''
<p>Dear ${designerData['name']},</p>
<p>I hope this message finds you well.</p>
<p>e were impressed with your design portfolio and
 would like to offer you an exciting opportunity to 
 collaborate with us on a new project.<br>
 The job details are as follows:
 </p>
 
 <p>${_descCtrl}</p>
 <p>  <strong>Start Date:</strong> ${_startDateCtrl} <br>
      <strong>End Date:</strong> ${_endDateCtrl} <br>
      <strong>Offer Rate:</strong> ${_rateCtrl} <br>
      
      <strong>Contact Phone No.:</strong> ${user!.phoneNumber} <br>
      <strong>Contact Email:</strong> ${user!.email} <br>   
 </p>
 
 <p>If you’re interested, please let us know by replying to 
 this email or contacting us directly. We look forward to the 
 possibility of working together.
 </p>
''',
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not send email: $e')));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job offered successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _textTitle({required String label}){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child:
      Text(
        label,
        style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _textFormField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    required String hintText,
    required int maxLength,
    bool multiline = false,
    bool enabled = true,
    bool hideCounter = false,
    Widget? prefix
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child:
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Value is missing';
          }
          return null;
        },
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: multiline ? 5 : 1 ,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefix: prefix,
          prefixStyle: TextStyle(color: Colors.white),
          counterText: hideCounter ? '' : null,
          enabled: enabled,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFFb9b9b9)),
          filled: true,
          fillColor: Colors.black54,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _textFormFieldDate({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: IgnorePointer(
          // prevents keyboard from appearing on tap
          child: TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return 'Value is missing';
              }
              return null;
            },
            controller: controller,
            enabled: enabled,
            key: ValueKey(valueKey),
            style: const TextStyle(color: Colors.white),
            maxLines: valueKey == 'JobDescription' ? 3 : 1,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_month, color: Colors.white),
              // right-aligned icon
              hintText: hint,
              hintStyle: TextStyle(color: Color(0xFFb9b9b9)),
              filled: true,
              fillColor: Colors.black54,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pickStartDateDialog() async {
    sDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      initialDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (sDate != null) {
      setState(() {
        _startDateCtrl.text =
        '${sDate!.day} - ${sDate!.month} - ${sDate!.year}';
        sDateTimestamp = Timestamp.fromMicrosecondsSinceEpoch(
          sDate!.microsecondsSinceEpoch,
        );
      });
    }
  }

  void _pickEndDateDialog() async {
    eDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      initialDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (eDate != null) {
      setState(() {
        _endDateCtrl.text =
        '${eDate!.day} - ${eDate!.month} - ${eDate!.year}';
        eDateTimestamp = Timestamp.fromMicrosecondsSinceEpoch(
          eDate!.microsecondsSinceEpoch,
        );
      });
    }
  }
}
