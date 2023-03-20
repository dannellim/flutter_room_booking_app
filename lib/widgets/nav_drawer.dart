import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            margin: EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.scaleDown,
                    image: AssetImage('images/flutter_logo.png'))),
            child: SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () => {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const TableEventsExample()),
              // )
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_online_rounded),
            title: const Text('Book a room'),
            onTap: () => {
              //Navigator.of(context).pop(),
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const RoomBookingPage()),
              // )
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () =>
                {Navigator.of(context).popUntil((route) => route.isFirst)},
          ),
        ],
      ),
    );
  }
}
