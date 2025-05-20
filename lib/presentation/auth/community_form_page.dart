import 'package:flutter/material.dart';

class CommunityFormPage extends StatefulWidget {
  const CommunityFormPage({super.key});

  @override
  State<CommunityFormPage> createState() => _CommunityFormPageState();
}

class _CommunityFormPageState extends State<CommunityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _homesCtrl = TextEditingController();
  final _customFacilityCtrl = TextEditingController();
  final List<String> _facilities = [];
  final List<String> _customFacilities = [];
  final bool _loading = false;
  String? _error;
  String? _logoPath;

  final List<String> _facilityOptions = [
    'Piscina',
    'Garaje',
    'Gimnasio',
    'Zonas verdes',
    'Pista de pádel',
    'Sala de reuniones',
  ];

  void _addCustomFacility() {
    final text = _customFacilityCtrl.text.trim();
    if (text.isNotEmpty && !_customFacilities.contains(text)) {
      setState(() {
        _customFacilities.add(text);
        _customFacilityCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos de la Comunidad')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la comunidad',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _homesCtrl,
                decoration: const InputDecoration(labelText: 'Nº de viviendas'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              const Text('Instalaciones disponibles:'),
              ..._facilityOptions.map(
                (f) => CheckboxListTile(
                  title: Text(f),
                  value: _facilities.contains(f),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _facilities.add(f);
                      } else {
                        _facilities.remove(f);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customFacilityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Añadir instalación personalizada',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCustomFacility,
                  ),
                ],
              ),
              ..._customFacilities.map(
                (f) => ListTile(
                  title: Text(f),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _customFacilities.remove(f);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // TODO: Widget para subir logo/foto de la comunidad
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Guardar datos en Firestore
                      }
                    },
                    child: const Text('Crear comunidad'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
