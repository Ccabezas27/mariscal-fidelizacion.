import 'package:flutter/material.dart';

void main() => runApp(const TioMariscalApp());

class TioMariscalApp extends StatelessWidget {
  const TioMariscalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tío Mariscal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF083B78)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const DemoShell(),
    );
  }
}

class Trip {
  Trip(this.invoice, this.date, this.status);
  final String invoice;
  final String date;
  String status;
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});
  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int index = 0;
  int approved = 0;
  int rewards = 0;
  final trips = <Trip>[
    Trip('FAC-001', '03/10/2026', 'Pendiente'),
  ];

  void addTrip(String invoice, String date) {
    if (trips.any((t) => t.invoice.toLowerCase() == invoice.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esta factura ya fue registrada.')));
      return;
    }
    setState(() => trips.insert(0, Trip(invoice, date, 'Pendiente')));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Factura enviada para validación.')));
  }

  void approve(Trip trip) {
    if (trip.status == 'Aprobada') return;
    setState(() {
      trip.status = 'Aprobada';
      approved++;
      if (approved >= 10) rewards++;
    });
  }

  void deliverReward() {
    if (rewards == 0) return;
    setState(() {
      rewards--;
      approved = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(approved: approved, rewards: rewards, onRegister: () => setState(() => index = 1)),
      TripsPage(trips: trips, onAdd: addTrip),
      RewardsPage(approved: approved, rewards: rewards),
      const ProfilePage(),
      AdminPage(trips: trips, rewards: rewards, onApprove: approve, onDeliver: deliverReward),
    ];
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Viajes'),
          NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Premios'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Admin'),
        ],
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
    child: Row(children: [
      ClipOval(child: Image.asset('assets/images/logo_ctms.jpg', width: 52, height: 52, fit: BoxFit.cover)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TÍO MARISCAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF083B78))),
        Text(title, style: const TextStyle(color: Colors.black54)),
      ])),
    ]),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.approved, required this.rewards, required this.onRegister});
  final int approved, rewards;
  final VoidCallback onRegister;
  @override
  Widget build(BuildContext context) {
    final remaining = (10 - approved).clamp(0, 10);
    return ListView(children: [
      const BrandHeader(title: 'Viaja, acumula y gana'),
      Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/images/tio_mariscal.jpg', height: 230, fit: BoxFit.contain)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Tu progreso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('$approved/10', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF083B78))),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: approved / 10, minHeight: 14, borderRadius: BorderRadius.circular(12)),
          const SizedBox(height: 12),
          Text(approved >= 10 ? '¡Felicitaciones! Has ganado un pasaje gratis con Mariscal Sucre.' : 'Te faltan $remaining viajes aprobados para ganar tu pasaje gratis.', textAlign: TextAlign.center),
          if (rewards > 0) Padding(padding: const EdgeInsets.only(top: 10), child: Text('Premios pendientes: $rewards', style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onRegister, icon: const Icon(Icons.add), label: const Text('REGISTRAR VIAJE'))),
        ]))),
      ),
      Padding(padding: const EdgeInsets.all(18), child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/images/bus_ctms.jpg', fit: BoxFit.cover))),
      const Padding(padding: EdgeInsets.fromLTRB(18, 0, 18, 24), child: Text('Viaja 10 veces y tu próximo pasaje va por cuenta de Mariscal Sucre.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
    ]);
  }
}

class TripsPage extends StatelessWidget {
  const TripsPage({super.key, required this.trips, required this.onAdd});
  final List<Trip> trips;
  final void Function(String, String) onAdd;
  @override
  Widget build(BuildContext context) => Column(children: [
    const BrandHeader(title: 'Mis viajes y facturas'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: SizedBox(width: double.infinity, child: FilledButton.icon(
      onPressed: () => showDialog(context: context, builder: (_) => RegisterTripDialog(onAdd: onAdd)),
      icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Registrar nueva factura')))),
    const SizedBox(height: 8),
    Expanded(child: trips.isEmpty ? const Center(child: Text('Todavía no has registrado viajes.')) : ListView.builder(
      padding: const EdgeInsets.all(12), itemCount: trips.length, itemBuilder: (_, i) {
        final t = trips[i];
        final icon = t.status == 'Aprobada' ? Icons.check_circle : t.status == 'Rechazada' ? Icons.cancel : Icons.schedule;
        return Card(child: ListTile(leading: Icon(icon), title: Text(t.invoice), subtitle: Text(t.date), trailing: Text(t.status, style: const TextStyle(fontWeight: FontWeight.bold))));
      })),
  ]);
}

class RegisterTripDialog extends StatefulWidget {
  const RegisterTripDialog({super.key, required this.onAdd});
  final void Function(String, String) onAdd;
  @override State<RegisterTripDialog> createState() => _RegisterTripDialogState();
}
class _RegisterTripDialogState extends State<RegisterTripDialog> {
  final invoice = TextEditingController();
  final date = TextEditingController(text: '03/10/2026');
  @override Widget build(BuildContext context) => AlertDialog(
    title: const Text('Registrar viaje'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: invoice, decoration: const InputDecoration(labelText: 'Número de factura')),
      TextField(controller: date, decoration: const InputDecoration(labelText: 'Fecha del viaje')),
      const SizedBox(height: 14),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Foto de factura (Firebase en fase 2)')),
    ]),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () {
      if (invoice.text.trim().isEmpty) return;
      widget.onAdd(invoice.text.trim(), date.text.trim()); Navigator.pop(context);
    }, child: const Text('Enviar'))],
  );
}

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key, required this.approved, required this.rewards});
  final int approved, rewards;
  @override Widget build(BuildContext context) => ListView(children: [
    const BrandHeader(title: 'Mis premios'),
    Padding(padding: const EdgeInsets.all(18), child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const Icon(Icons.card_giftcard, size: 70), const SizedBox(height: 12),
      Text(rewards > 0 ? '¡Tienes un pasaje gratis!' : 'Aún no tienes premios pendientes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 8), Text('Progreso actual: $approved/10'),
      if (rewards > 0) const Padding(padding: EdgeInsets.only(top: 16), child: Text('Presenta tu premio para validación. El administrador marcará el pasaje como entregado.', textAlign: TextAlign.center)),
    ]))),
  ]);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context) => ListView(children: const [
    BrandHeader(title: 'Mis datos'),
    ListTile(leading: Icon(Icons.person), title: Text('Pasajero demo'), subtitle: Text('Nombres y apellidos')),
    ListTile(leading: Icon(Icons.badge_outlined), title: Text('Cédula'), subtitle: Text('Se validará como única en Firebase')),
    ListTile(leading: Icon(Icons.phone_outlined), title: Text('Celular'), subtitle: Text('Registro de usuario')),
    ListTile(leading: Icon(Icons.email_outlined), title: Text('Correo electrónico'), subtitle: Text('Registro de usuario')),
  ]);
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key, required this.trips, required this.rewards, required this.onApprove, required this.onDeliver});
  final List<Trip> trips; final int rewards; final void Function(Trip) onApprove; final VoidCallback onDeliver;
  @override Widget build(BuildContext context) {
    final pending = trips.where((t) => t.status == 'Pendiente').toList();
    return ListView(children: [
      const BrandHeader(title: 'Panel administrativo — Demo'),
      Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 8, runSpacing: 8, children: [
        _stat('Facturas', '${trips.length}'), _stat('Pendientes', '${pending.length}'), _stat('Premios', '$rewards'),
      ])),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('Facturas pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ...pending.map((t) => Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: ListTile(
        title: Text(t.invoice), subtitle: Text(t.date), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(tooltip: 'Rechazar', onPressed: () => t.status = 'Rechazada', icon: const Icon(Icons.close)),
          IconButton(tooltip: 'Aprobar', onPressed: () => onApprove(t), icon: const Icon(Icons.check)),
        ]))),
      if (rewards > 0) Padding(padding: const EdgeInsets.all(18), child: FilledButton.icon(onPressed: onDeliver, icon: const Icon(Icons.redeem), label: const Text('Marcar premio como entregado e iniciar 0/10'))),
      const Padding(padding: EdgeInsets.all(18), child: Text('En producción, aprobar/rechazar y generar premios se hará mediante transacciones seguras de servidor.', textAlign: TextAlign.center)),
    ]);
  }
  Widget _stat(String label, String value) => SizedBox(width: 105, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(label)]))));
}
