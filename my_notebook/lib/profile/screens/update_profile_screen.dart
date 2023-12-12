import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_notebook/common/camera/services/camera_service.dart';
import 'package:my_notebook/common/storage/services/image_service.dart';
import 'package:my_notebook/profile/components/get_image.dart';
import 'package:my_notebook/profile/services/profile_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic>? profile;
  const UpdateProfileScreen({required this.user, this.profile, Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  String? imagePath;

  final _service = ProfileService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<String?> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String job = jobController.text.trim();
      String phone = phoneController.text.trim();
      String birthday = dateController.text.trim();

      try {
        if(imagePath != null && imagePath != widget.user.photoURL) {
          await ImageService().upload(uid: widget.user.uid, path: imagePath!);
          String? url = await ImageService().read(uid: widget.user.uid);
          
          if(url != null) {
            await widget.user.updatePhotoURL(url);
          }
        }

        if (name.isNotEmpty) await widget.user.updateDisplayName(name);
        if (email.isNotEmpty) await widget.user.updateEmail(email);
        if (job.isNotEmpty) await _service.updateJob(job: job);
        if (phone.isNotEmpty) await _service.updatePhone(phone: phone);
        if (birthday.isNotEmpty)
          await _service.updatebirthday(birthday: birthday);
        return 'Profile Updated';
      } on FirebaseAuthException {
        return 'Was not possible to update your profile.';
      }
    }

    return null;
  }

  void refreshImage({String? newPath}) {
    if (newPath != null) {
      imagePath = newPath.trim();
    } else if (widget.user.photoURL != null) {
      imagePath = widget.user.photoURL;
    }
  }

  @override
  void initState() {
    super.initState();
    refreshImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet<File?>(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.only(top: 16.0),
                          height: 200,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Camera'),
                                onTap: () {
                                  CameraService().takePicture().then(
                                    (value) {
                                      if (value.error != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(value.error!),
                                          backgroundColor: Colors.red.shade400,
                                        ));
                                      } else if (value.file != null) {
                                        Navigator.pop(context, value.file);
                                      }
                                    },
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Gallery'),
                                onTap: () {
                                  CameraService().getFromGallery().then(
                                    (value) {
                                      if (value.error != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(value.error!),
                                          backgroundColor: Colors.red.shade400,
                                        ));
                                      } else if (value.file != null) {
                                        Navigator.pop(context, value.file);
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          refreshImage(newPath: value.path);
                        });
                      }
                    });
                  },
                  child: getImage(photoURL: imagePath),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        value = (value != null) ? value.trim() : value;

                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 2) {
                          return 'Invalid name. It should be at least 2 characters';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        value = (value != null) ? value.trim() : value;

                        if (value != null &&
                            value.isNotEmpty &&
                            (value.length < 5 || !value.contains('@'))) {
                          return 'Invalid email address';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: jobController,
                      decoration: const InputDecoration(labelText: 'Job'),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        value = (value != null) ? value.trim() : value;

                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 2) {
                          return 'Invalid job. Enter a valid job';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

                        String formattedValue;
                        if (cleaned.isEmpty) {
                          formattedValue = cleaned;
                        } else if (cleaned.length <= 2) {
                          formattedValue =
                              '(${cleaned.substring(0, cleaned.length)}';
                        } else if (cleaned.length <= 6) {
                          formattedValue =
                              '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, cleaned.length)}';
                        } else if (cleaned.length <= 11) {
                          formattedValue =
                              '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7, cleaned.length)}';
                        } else {
                          formattedValue =
                              '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7, 11)}';
                        }

                        phoneController.value = TextEditingValue(
                          text: formattedValue,
                          selection: TextSelection.collapsed(
                              offset: formattedValue.length),
                        );
                      },
                      validator: (value) {
                        value = (value != null) ? value.trim() : value;

                        final RegExp phoneRegExp = RegExp(
                          r'^\(\d{2}\)\s9?[6-9]\d{3}-\d{4}$',
                        );

                        if (value != null &&
                            value.isNotEmpty &&
                            !phoneRegExp.hasMatch(value)) {
                          return 'Invalid phone number. It should be 10 digits';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Birthday'),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        value = (value != null) ? value.trim() : value;

                        if (value != null && value.isNotEmpty) {
                          final dateRegExp = RegExp(r'^\d{2}/\d{2}/\d{4}$');

                          if (!dateRegExp.hasMatch(value)) {
                            return 'Invalid date format. Please use dd/mm/yyyy';
                          }

                          final parts = value.split('/');
                          final day = int.tryParse(parts[0]);
                          final month = int.tryParse(parts[1]);
                          final year = int.tryParse(parts[2]);

                          if (day == null || month == null || year == null) {
                            return 'Invalid date values';
                          }

                          if (day < 1 ||
                              day > 31 ||
                              month < 1 ||
                              month > 12 ||
                              year < 1900) {
                            return 'Invalid date';
                          }
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _updateProfile().then((value) {
                            Navigator.pop(context, value);
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
