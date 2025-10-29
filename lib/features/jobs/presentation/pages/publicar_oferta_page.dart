import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/job_create_model.dart';
import '../../domain/repositories/jobs_repository.dart';

class PublicarOfertaPage extends StatefulWidget {
  const PublicarOfertaPage({super.key});

  @override
  State<PublicarOfertaPage> createState() => _PublicarOfertaPageState();
}

class _PublicarOfertaPageState extends State<PublicarOfertaPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String _selectedWorkMode = 'remote';
  String _selectedJobType = 'full_time';
  String _selectedExperienceLevel = 'mid';
  bool _isLoading = false;

  final List<String> _workModes = [
    'remote',
    'hybrid',
    'on_site',
  ];

  final List<String> _jobTypes = [
    'full_time',
    'part_time',
    'contract',
    'internship',
  ];

  final List<String> _experienceLevels = [
    'junior',
    'mid',
    'senior',
    'lead',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Oferta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Título del Trabajo',
                hint: 'Ej: Desarrollador Flutter Senior',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Descripción',
                hint: 'Describe las responsabilidades y requisitos del puesto...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Ubicación y Modalidad'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Ubicación',
                hint: 'Ej: Madrid, España',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La ubicación es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Modalidad de Trabajo',
                value: _selectedWorkMode,
                items: _workModes,
                onChanged: (value) => setState(() => _selectedWorkMode = value!),
                displayNames: {
                  'remote': 'Remoto',
                  'hybrid': 'Híbrido',
                  'on_site': 'Presencial',
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Detalles del Empleo'),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Tipo de Empleo',
                value: _selectedJobType,
                items: _jobTypes,
                onChanged: (value) => setState(() => _selectedJobType = value!),
                displayNames: {
                  'full_time': 'Tiempo Completo',
                  'part_time': 'Tiempo Parcial',
                  'contract': 'Contrato',
                  'internship': 'Prácticas',
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Nivel de Experiencia',
                value: _selectedExperienceLevel,
                items: _experienceLevels,
                onChanged: (value) => setState(() => _selectedExperienceLevel = value!),
                displayNames: {
                  'junior': 'Junior',
                  'mid': 'Mid-Level',
                  'senior': 'Senior',
                  'lead': 'Lead/Principal',
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Salario'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _salaryMinController,
                      label: 'Salario Mínimo',
                      hint: '30000',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final salary = int.tryParse(value);
                          if (salary == null || salary < 0) {
                            return 'Ingresa un número válido';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _salaryMaxController,
                      label: 'Salario Máximo',
                      hint: '50000',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final salary = int.tryParse(value);
                          if (salary == null || salary < 0) {
                            return 'Ingresa un número válido';
                          }
                          final minSalary = int.tryParse(_salaryMinController.text);
                          if (minSalary != null && salary < minSalary) {
                            return 'Debe ser mayor al mínimo';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Habilidades Requeridas'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _skillsController,
                label: 'Habilidades',
                hint: 'Flutter, Dart, Firebase, Git (separadas por comas)',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Publicar Oferta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    Map<String, String>? displayNames,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(displayNames?[item] ?? item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _submitJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final skills = _skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();

      final jobData = JobCreateModel(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        companyName: 'Mi Empresa', // TODO: Obtener de perfil de empresa
        location: _locationController.text.trim(),
        workMode: _selectedWorkMode,
        jobType: _selectedJobType,
        salaryMin: _salaryMinController.text.isNotEmpty 
            ? int.parse(_salaryMinController.text) 
            : null,
        salaryMax: _salaryMaxController.text.isNotEmpty 
            ? int.parse(_salaryMaxController.text) 
            : null,
        skills: skills,
        requirements: _selectedExperienceLevel, // Usar experienceLevel como requirements
      );

      // Crear el trabajo
      await Get.find<JobsRepository>().createJob(jobData);

      Get.snackbar(
        'Éxito',
        'Oferta de trabajo publicada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to company dashboard and replace current page
      Get.offNamed('/dashboard/empresa');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo publicar la oferta: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}