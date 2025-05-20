import 'package:flutter/material.dart';
import 'auth_text_field.dart';

class AuthForm extends StatefulWidget {
  final bool isAdmin;
  final void Function({
    required String email,
    required String password,
    String? confirm,
    String? communityId,
    String? name,
    String? flat,
    String? phone,
  })
  onSubmit;
  final bool showCommunityId;
  final bool showName;
  final bool showFlat;
  final bool showPhone;
  final bool showConfirm;
  final bool loading;
  final String? error;
  final String submitLabel;

  const AuthForm({
    super.key,
    required this.isAdmin,
    required this.onSubmit,
    this.showCommunityId = false,
    this.showName = false,
    this.showFlat = false,
    this.showPhone = false,
    this.showConfirm = true,
    this.loading = false,
    this.error,
    this.submitLabel = 'Registrar',
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _communityIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _flatCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordCtrl,
            label: 'Contraseña',
            obscureText: !_showPassword,
            validator:
                (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          if (widget.showConfirm) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmCtrl,
              label: 'Confirmar contraseña',
              obscureText: !_showConfirm,
              validator: (v) => v != _passwordCtrl.text ? 'No coincide' : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirm ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
            ),
          ],
          if (widget.showCommunityId) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _communityIdCtrl,
              label: 'ID de comunidad',
              validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
            ),
          ],
          if (widget.showName) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _nameCtrl,
              label: 'Nombre completo',
              validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
            ),
          ],
          if (widget.showFlat) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _flatCtrl,
              label: 'Piso/Puerta',
              validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
            ),
          ],
          if (widget.showPhone) ...[
            const SizedBox(height: 16),
            AuthTextField(
              controller: _phoneCtrl,
              label: 'Teléfono (opcional)',
              keyboardType: TextInputType.phone,
            ),
          ],
          const SizedBox(height: 24),
          if (widget.error != null)
            Text(widget.error!, style: const TextStyle(color: Colors.red)),
          widget.loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit(
                      email: _emailCtrl.text.trim(),
                      password: _passwordCtrl.text.trim(),
                      confirm: _confirmCtrl.text.trim(),
                      communityId: _communityIdCtrl.text.trim(),
                      name: _nameCtrl.text.trim(),
                      flat: _flatCtrl.text.trim(),
                      phone: _phoneCtrl.text.trim(),
                    );
                  }
                },
                child: Text(widget.submitLabel),
              ),
        ],
      ),
    );
  }
}
