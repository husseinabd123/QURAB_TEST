import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  late HijriCalendar _hijriDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _hijriDate = HijriCalendar.fromDate(_selectedDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقويم'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الهجري'),
            Tab(text: 'الميلادي'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTodayCard(),
          _buildConverter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHijriCalendar(),
                _buildGregorianCalendar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    final settingsAsync = ref.watch(settingsProvider);
    final hijriOffset = settingsAsync.valueOrNull?.hijriOffset ?? 0;
    final adjustedHijri = HijriCalendar.fromDate(_selectedDate);
    adjustedHijri.hDay += hijriOffset;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'اليوم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${adjustedHijri.hDay} ${adjustedHijri.getLongMonthName()} ${adjustedHijri.hYear} هـ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('dd MMMM yyyy', 'ar').format(_selectedDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConverter() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'محول التاريخ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('اختر تاريخاً'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showHijriAdjustment(),
                    child: const Text('تعديل التقويم'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriCalendar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الشهر الهجري الحالي',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildMonthGrid(isHijri: true),
          const SizedBox(height: 24),
          _buildIslamicEvents(),
        ],
      ),
    );
  }

  Widget _buildGregorianCalendar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الشهر الميلادي الحالي',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildMonthGrid(isHijri: false),
        ],
      ),
    );
  }

  Widget _buildMonthGrid({required bool isHijri}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              isHijri
                  ? '${_hijriDate.getLongMonthName()} ${_hijriDate.hYear}'
                  : DateFormat('MMMM yyyy', 'ar').format(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: isHijri ? _hijriDate.lengthOfMonth() : DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isToday = isHijri 
                    ? day == _hijriDate.hDay
                    : day == _selectedDate.day;

                return Container(
                  decoration: BoxDecoration(
                    color: isToday 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? Colors.white : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIslamicEvents() {
    final events = [
      {'date': '1 محرم', 'event': 'رأس السنة الهجرية'},
      {'date': '10 محرم', 'event': 'عاشوراء'},
      {'date': '12 ربيع الأول', 'event': 'المولد النبوي الشريف'},
      {'date': '13 رجب', 'event': 'مولد الإمام علي (ع)'},
      {'date': '15 شعبان', 'event': 'ليلة النصف من شعبان'},
      {'date': '1 رمضان', 'event': 'بداية شهر رمضان'},
      {'date': '21 رمضان', 'event': 'استشهاد الإمام علي (ع)'},
      {'date': '1 شوال', 'event': 'عيد الفطر'},
      {'date': '10 ذو الحجة', 'event': 'عيد الأضحى'},
      {'date': '18 ذو الحجة', 'event': 'عيد الغدير'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المناسبات الإسلامية',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...events.map((event) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(event['event']!),
            subtitle: Text(event['date']!),
          ),
        )),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hijriDate = HijriCalendar.fromDate(picked);
      });
    }
  }

  void _showHijriAdjustment() {
    final settingsAsync = ref.watch(settingsProvider);
    final currentOffset = settingsAsync.valueOrNull?.hijriOffset ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        int tempOffset = currentOffset;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('تعديل التقويم الهجري', textAlign: TextAlign.right),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'قم بتعديل التقويم الهجري حسب رؤية الهلال في منطقتك',
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setDialogState(() {
                            tempOffset--;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tempOffset > 0 ? '+$tempOffset' : '$tempOffset',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() {
                            tempOffset++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('أيام', style: TextStyle(fontSize: 16)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(settingsRepoProvider);
                    await repo.updateHijriOffset(tempOffset);
                    ref.invalidate(settingsProvider);
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {
                        _hijriDate = HijriCalendar.fromDate(_selectedDate);
                        _hijriDate.hDay += tempOffset;
                      });
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
