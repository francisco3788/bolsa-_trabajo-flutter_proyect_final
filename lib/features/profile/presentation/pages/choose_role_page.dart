import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/choose_role_controller.dart';

class ChooseRolePage extends GetView<ChooseRoleController> {
  const ChooseRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu experiencia'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Selecciona el rol con el que trabajaras en la plataforma. '
                  'Luego completa los datos minimos para personalizar tu inicio.',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: RoleOptionCard(
                        title: 'Candidato',
                        description:
                            'Busca oportunidades y encuentra vacantes alineadas contigo.',
                        isSelected: controller.isCandidateSelected,
                        isLoading: controller.selectingRole.value &&
                            controller.pendingRole.value == 'candidate',
                        onTap: controller.selectingRole.value
                            ? null
                            : () => controller.selectRole('candidate'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RoleOptionCard(
                        title: 'Empresa',
                        description:
                            'Publica vacantes y gestiona candidatos de forma agil.',
                        isSelected: controller.isCompanySelected,
                        isLoading: controller.selectingRole.value &&
                            controller.pendingRole.value == 'company',
                        onTap: controller.selectingRole.value
                            ? null
                            : () => controller.selectRole('company'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (controller.isCandidateSelected)
                  _CandidateForm(controller: controller),
                if (controller.isCompanySelected)
                  _CompanyForm(controller: controller),
                if (controller.selectedRole.value != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: TextButton(
                      onPressed: controller.savingProfile.value
                          ? null
                          : controller.cancelSelection,
                      child: const Text('Elegir otro rol'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoleOptionCard extends StatelessWidget {
  const RoleOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String description;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor =
        isSelected ? colorScheme.primary : colorScheme.outline;
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          color: backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            if (isLoading) ...[
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CandidateForm extends StatelessWidget {
  const _CandidateForm({required this.controller});

  final ChooseRoleController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.candidateFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Datos de candidato',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.candidateNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              hintText: 'Maria Perez',
            ),
            validator: (value) =>
                controller.validateRequired(value, 'El nombre'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.candidateLocationController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Ubicacion',
              hintText: 'Bogota, Colombia',
            ),
            validator: (value) =>
                controller.validateRequired(value, 'La ubicacion'),
          ),
          const SizedBox(height: 24),
          Obx(
            () => ElevatedButton(
              onPressed: controller.savingProfile.value
                  ? null
                  : () => controller.submitCandidateProfile(),
              child: controller.savingProfile.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Guardar y continuar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyForm extends StatelessWidget {
  const _CompanyForm({required this.controller});

  final ChooseRoleController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.companyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Datos de empresa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.companyNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre de la empresa',
              hintText: 'Acme Corp',
            ),
            validator: (value) =>
                controller.validateRequired(value, 'El nombre'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.companySectorController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Sector',
              hintText: 'Tecnologia, Educacion, Salud...',
            ),
            validator: (value) =>
                controller.validateRequired(value, 'El sector'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.companyLocationController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Ubicacion',
              hintText: 'Medellin, Colombia',
            ),
            validator: (value) =>
                controller.validateRequired(value, 'La ubicacion'),
          ),
          const SizedBox(height: 24),
          Obx(
            () => ElevatedButton(
              onPressed: controller.savingProfile.value
                  ? null
                  : () => controller.submitCompanyProfile(),
              child: controller.savingProfile.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Guardar y continuar'),
            ),
          ),
        ],
      ),
    );
  }
}
