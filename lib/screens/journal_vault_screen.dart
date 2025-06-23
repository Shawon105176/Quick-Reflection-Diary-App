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
                _buildJournalCovers(context),
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

  Widget _buildJournalCovers(BuildContext context) {
    final theme = Theme.of(context);

    // Mock journal covers data - in production, get from user's saved covers
    final List<Map<String, dynamic>> journalCovers = [
      {
        'id': 1,
        'title': 'My Daily Thoughts',
        'color': Colors.blue,
        'pattern': 'classic',
        'icon': Icons.book,
        'entryCount': 45,
        'lastModified': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 2,
        'title': 'Travel Adventures',
        'color': Colors.green,
        'pattern': 'travel',
        'icon': Icons.explore,
        'entryCount': 23,
        'lastModified': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': 3,
        'title': 'Mindful Moments',
        'color': Colors.purple,
        'pattern': 'zen',
        'icon': Icons.spa,
        'entryCount': 67,
        'lastModified': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 4,
        'title': 'Goals & Dreams',
        'color': Colors.orange,
        'pattern': 'motivational',
        'icon': Icons.star,
        'entryCount': 12,
        'lastModified': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': 5,
        'title': 'Gratitude Journal',
        'color': Colors.pink,
        'pattern': 'floral',
        'icon': Icons.favorite,
        'entryCount': 89,
        'lastModified': DateTime.now().subtract(const Duration(hours: 6)),
      },
      {
        'id': 6,
        'title': 'Creative Ideas',
        'color': Colors.teal,
        'pattern': 'artistic',
        'icon': Icons.palette,
        'entryCount': 34,
        'lastModified': DateTime.now().subtract(const Duration(days: 4)),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Journal Covers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showCreateCoverDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: journalCovers.length,
          itemBuilder: (context, index) {
            final cover = journalCovers[index];
            return _buildJournalCoverCard(context, cover);
          },
        ),
      ],
    );
  }

  Widget _buildJournalCoverCard(
    BuildContext context,
    Map<String, dynamic> cover,
  ) {
    final theme = Theme.of(context);
    final color = cover['color'] as Color;

    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openJournalCover(context, cover),
        onLongPress: () => _showCoverOptions(context, cover),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      cover['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cover['entryCount']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  cover['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatLastModified(cover['lastModified']),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (cover['entryCount'] / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastModified(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _openJournalCover(BuildContext context, Map<String, dynamic> cover) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JournalCoverDetailScreen(cover: cover),
      ),
    );
  }

  void _showCoverOptions(BuildContext context, Map<String, dynamic> cover) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildCoverOptionsSheet(context, cover),
    );
  }

  Widget _buildCoverOptionsSheet(
    BuildContext context,
    Map<String, dynamic> cover,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cover['title'],
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Cover'),
            onTap: () {
              Navigator.pop(context);
              _showEditCoverDialog(context, cover);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Export as Book'),
            onTap: () {
              Navigator.pop(context);
              _showExportDialog(context, coverData: cover);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Duplicate Cover'),
            onTap: () {
              Navigator.pop(context);
              _duplicateCover(context, cover);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Delete Cover',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteCoverDialog(context, cover);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateCoverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => JournalCoverCreatorDialog(),
    );
  }

  void _showEditCoverDialog(BuildContext context, Map<String, dynamic> cover) {
    showDialog(
      context: context,
      builder: (context) => JournalCoverCreatorDialog(existingCover: cover),
    );
  }

  void _duplicateCover(BuildContext context, Map<String, dynamic> cover) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cover['title']} duplicated successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteCoverDialog(
    BuildContext context,
    Map<String, dynamic> cover,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Cover'),
            content: Text(
              'Are you sure you want to delete "${cover['title']}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${cover['title']} deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
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

  void _showExportDialog(
    BuildContext context, {
    String? initialFormat,
    Map<String, dynamic>? coverData,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => ExportOptionsDialog(
            initialFormat: initialFormat,
            coverData: coverData,
          ),
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
  final Map<String, dynamic>? coverData;

  const ExportOptionsDialog({super.key, this.initialFormat, this.coverData});

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

    // Set default values from cover data if available
    if (widget.coverData != null) {
      _titleController.text = widget.coverData!['title'] ?? 'My Journal';
      _authorController.text = 'Journal Author';
    } else {
      _titleController.text = 'My Journal';
      _authorController.text = 'Author Name';
    }
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

// Journal Cover Detail Screen
class JournalCoverDetailScreen extends StatelessWidget {
  final Map<String, dynamic> cover;

  const JournalCoverDetailScreen({super.key, required this.cover});
  @override
  Widget build(BuildContext context) {
    final color = cover['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Text(cover['title']),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showOptionsMenu(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.3), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCoverPreview(context),
            const SizedBox(height: 24),
            _buildQuickStats(context),
            const SizedBox(height: 24),
            _buildRecentEntries(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPreview(BuildContext context) {
    final theme = Theme.of(context);
    final color = cover['color'] as Color;

    return Card(
      elevation: 8,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cover['icon'] as IconData, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                cover['title'],
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Journal Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Entries',
                  '${cover['entryCount']}',
                  Icons.edit_note,
                ),
                _buildStatItem(
                  'Days',
                  '${(cover['entryCount'] as int) + 5}',
                  Icons.calendar_today,
                ),
                _buildStatItem(
                  'Words',
                  '${(cover['entryCount'] as int) * 150}',
                  Icons.text_fields,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: cover['color'] as Color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecentEntries(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Entries',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final dates = ['Today', 'Yesterday', '2 days ago'];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: (cover['color'] as Color).withOpacity(0.2),
                    child: Text('${index + 1}'),
                  ),
                  title: Text('Entry ${index + 1}'),
                  subtitle: Text(dates[index]),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to specific entry
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Add new entry to this cover
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Entry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cover['color'] as Color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Edit cover settings
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Cover'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Export this cover as book
                },
                icon: const Icon(Icons.download),
                label: const Text('Export'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Cover'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Duplicate'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Archive'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }
}

// Journal Cover Creator Dialog
class JournalCoverCreatorDialog extends StatefulWidget {
  final Map<String, dynamic>? existingCover;

  const JournalCoverCreatorDialog({super.key, this.existingCover});

  @override
  State<JournalCoverCreatorDialog> createState() =>
      _JournalCoverCreatorDialogState();
}

class _JournalCoverCreatorDialogState extends State<JournalCoverCreatorDialog>
    with SafeStateMixin {
  late TextEditingController _titleController;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.book;
  String _selectedPattern = 'classic';

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  final List<IconData> _iconOptions = [
    Icons.book,
    Icons.menu_book,
    Icons.auto_stories,
    Icons.library_books,
    Icons.edit_note,
    Icons.note_alt,
    Icons.spa,
    Icons.explore,
    Icons.star,
    Icons.favorite,
    Icons.palette,
    Icons.psychology,
  ];

  final List<String> _patternOptions = [
    'classic',
    'modern',
    'vintage',
    'minimalist',
    'artistic',
    'travel',
    'zen',
    'motivational',
    'floral',
    'geometric',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingCover?['title'] ?? '',
    );
    if (widget.existingCover != null) {
      _selectedColor = widget.existingCover!['color'] as Color;
      _selectedIcon = widget.existingCover!['icon'] as IconData;
      _selectedPattern = widget.existingCover!['pattern'] as String;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingCover != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(_selectedIcon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Cover' : 'Create New Cover',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Cover Title',
                        hintText: 'My Amazing Journal',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Color Selection
                    Text(
                      'Choose Color',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _colorOptions.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap:
                                  () => safeSetState(
                                    () => _selectedColor = color,
                                  ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: Colors.black,
                                            width: 3,
                                          )
                                          : null,
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Icon Selection
                    Text(
                      'Choose Icon',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _iconOptions.map((icon) {
                            final isSelected = _selectedIcon == icon;
                            return GestureDetector(
                              onTap:
                                  () =>
                                      safeSetState(() => _selectedIcon = icon),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? _selectedColor.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: _selectedColor,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Icon(
                                  icon,
                                  color:
                                      isSelected ? _selectedColor : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Pattern Selection
                    Text(
                      'Choose Pattern',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _patternOptions.map((pattern) {
                            final isSelected = _selectedPattern == pattern;
                            return FilterChip(
                              label: Text(pattern.toUpperCase()),
                              selected: isSelected,
                              onSelected: (selected) {
                                safeSetState(() => _selectedPattern = pattern);
                              },
                              selectedColor: _selectedColor.withOpacity(0.2),
                              checkmarkColor: _selectedColor,
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed:
                        _titleController.text.isNotEmpty ? _saveCover : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCover() {
    final coverData = {
      'id':
          widget.existingCover?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'title': _titleController.text.trim(),
      'color': _selectedColor,
      'pattern': _selectedPattern,
      'icon': _selectedIcon,
      'entryCount': widget.existingCover?['entryCount'] ?? 0,
      'lastModified': DateTime.now(),
    };

    // TODO: Save coverData to persistent storage
    debugPrint('Saving cover: ${coverData['title']}');

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingCover != null
              ? 'Cover updated successfully!'
              : 'New cover created successfully!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
