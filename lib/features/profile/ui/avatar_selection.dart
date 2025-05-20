import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarSelectionPage extends StatefulWidget {
  final List<String> availableAvatars;
  final String selectedAvatar;

  const AvatarSelectionPage({
    Key? key,
    required this.availableAvatars,
    required this.selectedAvatar,
  }) : super(key: key);

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.selectedAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pilih Avatar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF131927),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 16,
            height: 16,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.availableAvatars.length,
              itemBuilder: (context, index) {
                final avatar = widget.availableAvatars[index];
                final isSelected = avatar == _selectedAvatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(color: Colors.green, width: 4)
                                  : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(avatar, fit: BoxFit.cover),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(0),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: // pada tombol ElevatedButton di AvatarSelectionPage
                  ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _selectedAvatar,
                  ); // kembalikan avatar yg dipilih
                },
                child: const Text(
                  'Pilih Avatar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
