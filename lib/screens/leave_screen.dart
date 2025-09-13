import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isLoading = false;
  String _responseMessage = "";

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _responseMessage = "";
    });

    final url = Uri.parse(
      "https://leave-management-be-ns80.onrender.com/leave/api/",
    );
    final body = {
      "employee_name": _nameController.text,
      "employee_email": _emailController.text,
      "start_date": _startDateController.text,
      "end_date": _endDateController.text,
      "reason": _reasonController.text,
    };

    try {
      print("📤 Sending POST request to $url");
      print("📦 Payload: $body");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      print("✅ Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _responseMessage = "Leave submitted successfully!";
        });
        _formKey.currentState!.reset();
      } else {
        setState(() {
          _responseMessage = "Failed to submit leave. Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text = pickedDate.toIso8601String().split("T")[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Leave Request Form",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: const Color(0xFF37474F),
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: isMobile ? double.infinity : 500,
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildTextField(_nameController, "Employee Name"),
                    _buildTextField(
                      _emailController,
                      "Email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildDateField(
                      _startDateController,
                      "Start Date",
                      context,
                    ),
                    _buildDateField(_endDateController, "End Date", context),
                    _buildTextField(_reasonController, "Reason", maxLines: 3),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitLeave,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Submit Leave",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    if (_responseMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _responseMessage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(context, controller),
        validator: (value) =>
            value == null || value.isEmpty ? "Please select $label" : null,
      ),
    );
  }
}
