import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../utils/safe_provider_base.dart';

class ExportOptions {
  final String format;
  final String title;
  final String author;
  final bool includePhotos;
  final bool includeMoodData;
  final DateTimeRange? dateRange;
  final List<String> selectedTags;
  final String theme;

  ExportOptions({
    required this.format,
    required this.title,
    required this.author,
    this.includePhotos = true,
    this.includeMoodData = false,
    this.dateRange,
    required this.selectedTags,
    required this.theme,
  });
}

class JournalExportProvider extends ChangeNotifier {
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String? _lastExportPath;

  bool get isExporting => _isExporting;
  double get exportProgress => _exportProgress;
  String? get lastExportPath => _lastExportPath;

  final List<String> _availableFormats = ['PDF', 'EPUB', 'Text'];
  final List<String> _availableThemes = [
    'Classic',
    'Modern',
    'Vintage',
    'Minimalist',
    'Colorful',
  ];

  List<String> get availableFormats => _availableFormats;
  List<String> get availableThemes => _availableThemes;

  Future<void> exportJournal(ExportOptions options) async {
    _isExporting = true;
    _exportProgress = 0.0;
    notifyListeners();

    try {
      // Simulate export process with progress updates
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        _exportProgress = i / 100.0;
        notifyListeners();
      }

      // Generate export file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${options.title.replaceAll(' ', '_')}.${options.format.toLowerCase()}';
      final filePath = '${directory.path}/$fileName';

      // Create mock export file
      await _createExportFile(filePath, options);

      _lastExportPath = filePath;
      _isExporting = false;
      notifyListeners();
    } catch (e) {
      _isExporting = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _createExportFile(String filePath, ExportOptions options) async {
    // This is a mock implementation
    // In a real app, you would use PDF generation libraries like pdf, printing, etc.
    final file = File(filePath);

    final content = '''
${options.title}
By ${options.author}

Generated on ${DateTime.now().toString()}

This is a mock ${options.format} export of your journal entries.
Theme: ${options.theme}
Include Photos: ${options.includePhotos}
Include Mood Data: ${options.includeMoodData}

In a real implementation, this would contain:
- All your journal entries from the selected date range
- Formatted according to the chosen theme
- Photos and mood data if selected
- Professional book-like layout

[Journal entries would be formatted here...]
''';

    await file.writeAsString(content);
  }

  void resetExport() {
    _isExporting = false;
    _exportProgress = 0.0;
    _lastExportPath = null;
    notifyListeners();
  }
}

class JournalVaultScreen extends StatefulWidget {
  const JournalVaultScreen({super.key});

  @override
  State<JournalVaultScreen> createState() => _JournalVaultScreenState();
}

class _JournalVaultScreenState extends State<JournalVaultScreen>
    with TickerProviderStateMixin, SafeStateMixin, SafeAnimationMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JournalExportProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Journal Vault'), elevation: 0),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context),
                const SizedBox(height: 24),
                _buildExportFormats(context),
                const SizedBox(height: 24),
                _buildPreviousExports(context),
                const SizedBox(height: 24),
                _buildFeatureHighlights(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transform Your Journal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create beautiful books from your journal entries',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showExportDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Export to Book'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportFormats(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Formats',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<JournalExportProvider>(
          builder: (context, provider, child) {
            return Row(
              children:
                  provider.availableFormats.map((format) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: _buildFormatCard(context, format),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormatCard(BuildContext context, String format) {
    final theme = Theme.of(context);

    IconData icon;
    String description;

    switch (format) {
      case 'PDF':
        icon = Icons.picture_as_pdf;
        description = 'Perfect for printing and sharing';
        break;
      case 'EPUB':
        icon = Icons.menu_book;
        description = 'E-book format for digital readers';
        break;
      case 'Text':
        icon = Icons.text_snippet;
        description = 'Simple text format';
        break;
      default:
        icon = Icons.description;
        description = 'Export format';
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showExportDialog(context, initialFormat: format),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                format,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousExports(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Exports',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<JournalExportProvider>(
          builder: (context, provider, child) {
            if (provider.lastExportPath == null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No exports yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your exported books will appear here',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text('Last Export'),
                subtitle: Text(provider.lastExportPath!.split('/').last),
                trailing: IconButton(
                  onPressed:
                      () => _showExportLocation(
                        context,
                        provider.lastExportPath!,
                      ),
                  icon: const Icon(Icons.folder),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureHighlights(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          context,
          Icons.auto_awesome,
          'AI-Enhanced Formatting',
          'Intelligent organization and beautiful layouts',
        ),
        _buildFeatureItem(
          context,
          Icons.photo_library,
          'Photo Integration',
          'Include your photos with smart placement',
        ),
        _buildFeatureItem(
          context,
          Icons.analytics,
          'Mood Analytics',
          'Visual charts of your emotional journey',
        ),
        _buildFeatureItem(
          context,
          Icons.palette,
          'Custom Themes',
          'Multiple professional book themes',
        ),
        _buildFeatureItem(
          context,
          Icons.date_range,
          'Date Range Selection',
          'Export specific time periods',
        ),
        _buildFeatureItem(
          context,
          Icons.cloud_upload,
          'Cloud Storage',
          'Save to Google Drive, Dropbox, or iCloud',
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, {String? initialFormat}) {
    showDialog(
      context: context,
      builder: (context) => ExportOptionsDialog(initialFormat: initialFormat),
    );
  }

  void _showExportLocation(BuildContext context, String path) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your journal has been exported to:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    path,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class ExportOptionsDialog extends StatefulWidget {
  final String? initialFormat;

  const ExportOptionsDialog({super.key, this.initialFormat});

  @override
  State<ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<ExportOptionsDialog>
    with SafeStateMixin {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String _selectedFormat = 'PDF';
  String _selectedTheme = 'Classic';
  bool _includePhotos = true;
  bool _includeMoodData = false;
  DateTimeRange? _dateRange;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.initialFormat ?? 'PDF';
    _titleController.text = 'My Journal';
    _authorController.text = 'Author Name';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.download,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Export to Book',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Consumer<JournalExportProvider>(
                builder: (context, provider, child) {
                  if (provider.isExporting) {
                    return _buildExportProgress(context, provider);
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Info
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Book Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Author Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Format Selection
                        Text(
                          'Export Format',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedFormat,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items:
                              provider.availableFormats.map((format) {
                                return DropdownMenuItem(
                                  value: format,
                                  child: Text(format),
                                );
                              }).toList(),
                          onChanged: (value) {
                            safeSetState(() => _selectedFormat = value!);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Theme Selection
                        Text(
                          'Book Theme',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedTheme,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items:
                              provider.availableThemes.map((theme) {
                                return DropdownMenuItem(
                                  value: theme,
                                  child: Text(theme),
                                );
                              }).toList(),
                          onChanged: (value) {
                            safeSetState(() => _selectedTheme = value!);
                          },
                        ),
                        const SizedBox(height: 24),

                        // Options
                        Text(
                          'Include Content',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Photos'),
                          subtitle: const Text(
                            'Include images in your entries',
                          ),
                          value: _includePhotos,
                          onChanged: (value) {
                            safeSetState(() => _includePhotos = value);
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Mood Data'),
                          subtitle: const Text(
                            'Include mood charts and analytics',
                          ),
                          value: _includeMoodData,
                          onChanged: (value) {
                            safeSetState(() => _includeMoodData = value);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date Range
                        Text(
                          'Date Range',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDateRange,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _dateRange == null
                                      ? 'All entries'
                                      : '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                                ),
                                const Spacer(),
                                if (_dateRange != null)
                                  IconButton(
                                    onPressed: () {
                                      safeSetState(() => _dateRange = null);
                                    },
                                    icon: const Icon(Icons.clear, size: 16),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Actions
            Consumer<JournalExportProvider>(
              builder: (context, provider, child) {
                if (provider.isExporting) {
                  return const SizedBox.shrink();
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _canExport() ? _startExport : null,
                        icon: const Icon(Icons.download),
                        label: const Text('Export'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportProgress(
    BuildContext context,
    JournalExportProvider provider,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Creating Your Book',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we format your journal entries...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(
            value: provider.exportProgress,
            backgroundColor: theme.colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '${(provider.exportProgress * 100).toInt()}%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _canExport() {
    return _titleController.text.trim().isNotEmpty &&
        _authorController.text.trim().isNotEmpty;
  }

  Future<void> _startExport() async {
    final options = ExportOptions(
      format: _selectedFormat,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      includePhotos: _includePhotos,
      includeMoodData: _includeMoodData,
      dateRange: _dateRange,
      selectedTags: List.from(_selectedTags),
      theme: _selectedTheme,
    );

    try {
      await context.read<JournalExportProvider>().exportJournal(options);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Journal exported successfully!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Open file location or share
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      safeSetState(() => _dateRange = picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
