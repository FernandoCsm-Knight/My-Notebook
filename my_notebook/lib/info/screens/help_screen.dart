import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Welcome to MyNotebook App!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
            Divider(),
            ListTile(
              title: Text(
                '1. Creating a Note:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
            ListTile(
              title: Text(
                'Tap the floating action button to create a new note. Give it a title and start taking notes.',
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                '2. PDF Conversion to TTS:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
            ListTile(
              title: Text(
                '   - Tap the "scanner" button.',
              ),
            ),
            ListTile(
              title: Text(
                '   - Select a PDF file from your device or cloud storage.',
              ),
            ),
            ListTile(
              title: Text(
                '   - The PDF content will be displayed at the upload screen.',
              ),
            ),
            ListTile(
              title: Text(
                '   - Select the pdf you want to convert to TTS.',
              ),
            ),
            ListTile(
              title: Text(
                '   - Tap the convert button to convert the PDF to TTS.',
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                '3. Note Management:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
            ListTile(
              title: Text(
                '   - Edit notes by tapping at the note.',
              ),
            ),
            ListTile(
              title: Text(
                '   - Delete notes by swiping left.',
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                '4. Share pdfs with other users:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Text(
                '   - Click at the "+" button at the top of the screen where you see your pdf file. This will share the pdf with other users.',
              ),
            ),
            ListTile(
              title: Text(
                '   - Go to search page and search for the pdfs you already shared with other users.',
              ),
            ),
            ListTile(
              title: Text(
                '   - See your posts by selecting your published pdfs and manage the comments.',
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                '5. Settings and Preferences:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
            ListTile(
              title: Text(
                '   - Customize app settings and more from the settings menu.',
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                '6. Support and Feedback:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.all(0),
            ),
            ListTile(
              title: Text(
                '   - If you encounter any issues or have suggestions, please contact our support team or provide feedback through the email fernandocsdm@gmail.com.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}