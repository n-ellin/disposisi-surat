// lib/shared/widgets/date_range_filter_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';

class DateRangeFilterResult {
  final DateTime? startDate;
  final DateTime? endDate;
  final String activeChip;
  final String dateFilterLabel;

  const DateRangeFilterResult({
    required this.startDate,
    required this.endDate,
    required this.activeChip,
    required this.dateFilterLabel,
  });
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 8) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(text[i]);
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class DateRangeFilterBottomSheet {
  static Future<DateRangeFilterResult?> show({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    String initialChip = 'Hari ini',
  }) async {
    return await showDialog<DateRangeFilterResult>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        final w = MediaQuery.of(context).size.width;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: w * 0.06),
          elevation: 0,
          child: _DateRangeFilterContent(
            initialStartDate: initialStartDate,
            initialEndDate: initialEndDate,
            initialChip: initialChip,
          ),
        );
      },
    );
  }
}

class _DateRangeFilterContent extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String initialChip;

  const _DateRangeFilterContent({
    this.initialStartDate,
    this.initialEndDate,
    required this.initialChip,
  });

  @override
  State<_DateRangeFilterContent> createState() =>
      _DateRangeFilterContentState();
}

class _DateRangeFilterContentState extends State<_DateRangeFilterContent> {
  late DateTime? tempStart;
  late DateTime? tempEnd;
  late String selectedChip;

  late TextEditingController _startController;
  late TextEditingController _endController;

  bool _startError = false;
  bool _endError = false;

  static const List<String> _chips = ['Hari ini', 'Bulan ini', 'Pilih tanggal'];

  final DateTime _firstDate = DateTime(DateTime.now().year - 5, 1, 1);
  final DateTime _lastDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    tempStart = widget.initialStartDate;
    tempEnd = widget.initialEndDate;
    selectedChip = widget.initialChip;

    _startController = TextEditingController(
      text: _dateToString(widget.initialStartDate),
    );
    _endController = TextEditingController(
      text: _dateToString(widget.initialEndDate),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  String _dateToString(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime? _parseDate(String val) {
    try {
      if (val.length != 10) return null;
      final parts = val.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;
      if (year < _firstDate.year || year > _lastDate.year) return null;
      final date = DateTime(year, month, day);

      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      // Validasi tidak melebihi hari ini
      if (date.isAfter(_lastDate)) return null;
      return date;
    } catch (_) {
      return null;
    }
  }

  void _onChipTap(String label) {
    final now = _lastDate; // pakai _lastDate supaya konsisten (date only)
    setState(() {
      selectedChip = label;
      _startError = false;
      _endError = false;
      if (label == 'Hari ini') {
        tempStart = now;
        tempEnd = now;
        _startController.text = _dateToString(now);
        _endController.text = _dateToString(now);
      } else if (label == 'Bulan ini') {
        tempStart = DateTime(now.year, now.month, 1);
        tempEnd = now;
        _startController.text = _dateToString(tempStart);
        _endController.text = _dateToString(now);
      } else {
        tempStart = null;
        tempEnd = null;
        _startController.clear();
        _endController.clear();
      }
    });
  }

  // Buka custom calendar picker pakai table_calendar
  Future<void> _openDatePicker({required bool isStart}) async {
    final initial = isStart ? (tempStart ?? _lastDate) : (tempEnd ?? _lastDate);

    // Clamp initial ke range valid
    final safeInitial = initial.isAfter(_lastDate)
        ? _lastDate
        : initial.isBefore(_firstDate)
        ? _firstDate
        : initial;

    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => _TableCalendarDialog(
        initialDate: safeInitial,
        firstDate: _firstDate,
        lastDate: _lastDate,
        // Untuk field "Sampai", firstDate-nya minimal = tempStart
        minSelectableDate: (!isStart && tempStart != null)
            ? tempStart!
            : _firstDate,
      ),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        tempStart = picked;
        _startController.text = _dateToString(picked);
        _startError = false;
        // Reset end kalau start > end
        if (tempEnd != null && picked.isAfter(tempEnd!)) {
          tempEnd = null;
          _endController.clear();
          _endError = false;
        }
      } else {
        tempEnd = picked;
        _endController.text = _dateToString(picked);
        _endError = false;
      }
    });
  }

  void _onManualChanged(String val, {required bool isStart}) {
    if (val.length < 10) {
      setState(() {
        if (isStart) {
          tempStart = null;
          _startError = false;
        } else {
          tempEnd = null;
          _endError = false;
        }
      });
      return;
    }

    final date = _parseDate(val);
    setState(() {
      if (isStart) {
        if (date == null) {
          _startError = true;
          tempStart = null;
        } else {
          _startError = false;
          tempStart = date;
          if (tempEnd != null && date.isAfter(tempEnd!)) {
            tempEnd = null;
            _endController.clear();
            _endError = false;
          }
        }
      } else {
        if (date == null) {
          _endError = true;
          tempEnd = null;
        } else if (tempStart != null && date.isBefore(tempStart!)) {
          _endError = true;
          tempEnd = null;
        } else {
          _endError = false;
          tempEnd = date;
        }
      }
    });
  }

  String _buildLabel() {
    if (selectedChip == 'Hari ini') return 'Hari ini';
    if (selectedChip == 'Bulan ini') return 'Bulan ini';
    if (tempStart != null && tempEnd != null) {
      return '${_dateToString(tempStart)} - ${_dateToString(tempEnd)}';
    }
    return 'Semua tanggal';
  }

  bool get _canApply {
    if (selectedChip != 'Pilih tanggal') return true;
    return tempStart != null && tempEnd != null && !_startError && !_endError;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.05),
      ),
      padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.05, w * 0.05, w * 0.06),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Tanggal',
            style: TextStyle(
              fontSize: (w * 0.042).clamp(15.0, 18.0),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: w * 0.035),

          // Chips
          Row(
            children: _chips.map((label) {
              final isActive = selectedChip == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onChipTap(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: label != _chips.last
                        ? EdgeInsets.only(right: w * 0.02)
                        : EdgeInsets.zero,
                    padding: EdgeInsets.symmetric(vertical: w * 0.025),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.bluePrimary : Colors.white,
                      borderRadius: BorderRadius.circular(w * 0.05),
                      border: Border.all(
                        color: isActive
                            ? AppColors.bluePrimary
                            : const Color(0xFFD1D5DB),
                        width: 1.2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.bluePrimary.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (w * 0.032).clamp(11.0, 14.0),
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (selectedChip == 'Pilih tanggal') ...[
            SizedBox(height: w * 0.045),
            _fieldTanggal(
              label: 'Dari',
              controller: _startController,
              isStart: true,
              hasError: _startError,
              errorText: 'Tanggal tidak valid',
              w: w,
            ),
            SizedBox(height: w * 0.03),
            _fieldTanggal(
              label: 'Sampai',
              controller: _endController,
              isStart: false,
              hasError: _endError,
              errorText: tempStart != null && _endError
                  ? 'Tidak boleh sebelum tanggal awal'
                  : 'Tanggal tidak valid',
              w: w,
            ),
          ],

          SizedBox(height: w * 0.05),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canApply
                  ? () {
                      Navigator.pop(
                        context,
                        DateRangeFilterResult(
                          startDate: tempStart,
                          endDate: tempEnd,
                          activeChip: selectedChip,
                          dateFilterLabel: _buildLabel(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: EdgeInsets.symmetric(vertical: w * 0.035),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.03),
                ),
              ),
              child: Text(
                'Terapkan Filter',
                style: TextStyle(
                  fontSize: (w * 0.037).clamp(13.0, 16.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldTanggal({
    required String label,
    required TextEditingController controller,
    required bool isStart,
    required bool hasError,
    required String errorText,
    required double w,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: (w * 0.034).clamp(12.0, 15.0),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: w * 0.015),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _DateInputFormatter(),
          ],
          style: TextStyle(fontSize: (w * 0.037).clamp(13.0, 16.0)),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: (w * 0.037).clamp(13.0, 16.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.calendar_today_rounded,
                size: (w * 0.05).clamp(18.0, 22.0),
                color: AppColors.bluePrimary,
              ),
              onPressed: () => _openDatePicker(isStart: isStart),
            ),
            filled: true,
            fillColor: hasError ? Colors.red.shade50 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(w * 0.03),
              borderSide: const BorderSide(color: Color(0xFFE2E5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(w * 0.03),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : const Color(0xFFE2E5EA),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(w * 0.03),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : AppColors.bluePrimary,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: w * 0.035,
              vertical: w * 0.03,
            ),
            errorText: hasError ? errorText : null,
            errorStyle: TextStyle(
              fontSize: (w * 0.03).clamp(10.0, 12.0),
              color: Colors.red.shade600,
            ),
          ),
          onChanged: (val) => _onManualChanged(val, isStart: isStart),
        ),
      ],
    );
  }
}

// ─── Custom TableCalendar Dialog ───────────────────────────────────────────

class _TableCalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime minSelectableDate;

  const _TableCalendarDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.minSelectableDate,
  });

  @override
  State<_TableCalendarDialog> createState() => _TableCalendarDialogState();
}

class _TableCalendarDialogState extends State<_TableCalendarDialog> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  bool _showPicker = false;

  late FixedExtentScrollController _monthScrollCtrl;
  late FixedExtentScrollController _yearScrollCtrl;

  late int _tempMonth;
  late int _tempYear;

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  List<int> get _validYears {
    final years = <int>[];
    for (int y = widget.firstDate.year; y <= widget.lastDate.year; y++) {
      years.add(y);
    }
    return years;
  }

  bool _isSelectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final min = DateTime(
      widget.minSelectableDate.year,
      widget.minSelectableDate.month,
      widget.minSelectableDate.day,
    );
    final max = DateTime(
      widget.lastDate.year,
      widget.lastDate.month,
      widget.lastDate.day,
    );
    return !d.isBefore(min) && !d.isAfter(max);
  }

  @override
  void initState() {
    super.initState();

    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;

    _tempMonth = widget.initialDate.month;
    _tempYear = widget.initialDate.year;

    final minMonth = _tempYear == widget.firstDate.year
        ? widget.firstDate.month
        : 1;

    _monthScrollCtrl = FixedExtentScrollController(
      initialItem: _tempMonth - minMonth,
    );

    _yearScrollCtrl = FixedExtentScrollController(
      initialItem: _validYears.indexOf(_tempYear),
    );
  }

  @override
  void dispose() {
    _monthScrollCtrl.dispose();
    _yearScrollCtrl.dispose();
    super.dispose();
  }

  void _openPicker() {
    _tempMonth = _focusedDay.month;
    _tempYear = _focusedDay.year;
    final minMonth = _tempYear == widget.firstDate.year
        ? widget.firstDate.month
        : 1;

    _monthScrollCtrl.jumpToItem(_tempMonth - minMonth);
    _yearScrollCtrl.jumpToItem(
      _validYears.indexOf(_tempYear).clamp(0, _validYears.length - 1),
    );
    setState(() => _showPicker = true);
  }

  void _applyPicker() {
    int month = _tempMonth;
    if (_tempYear == widget.lastDate.year && month > widget.lastDate.month) {
      month = widget.lastDate.month;
    }
    if (_tempYear == widget.firstDate.year && month < widget.firstDate.month) {
      month = widget.firstDate.month;
    }
    setState(() {
      _focusedDay = DateTime(_tempYear, month, 1);
      _showPicker = false;
      if (_selectedDay != null && !_isSelectable(_selectedDay!)) {
        _selectedDay = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(w * 0.05),
        ),
        padding: EdgeInsets.all(w * 0.04),
        // AnimatedSize supaya container menyesuaikan tinggi saat ganti page
        child: AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Page switch dalam 1 container ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) {
                  // Slide dari kanan masuk, slide ke kiri keluar
                  final inFromRight =
                      Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      );
                  final outToLeft =
                      Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      );
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: child.key == const ValueKey('picker')
                          ? const Offset(1, 0)
                          : const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: _showPicker
                    ? _buildPickerPage(w)
                    : _buildCalendarPage(w),
              ),

              SizedBox(height: w * 0.03),

              // ── Tombol Batal / Pilih (selalu tampil) ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showPicker
                          ? setState(() => _showPicker = false)
                          : Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: w * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                        ),
                      ),
                      child: Text(
                        _showPicker ? 'Kembali' : 'Batal',
                        style: TextStyle(
                          fontSize: (w * 0.035).clamp(12.0, 15.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showPicker
                          ? _applyPicker
                          : (_selectedDay != null
                                ? () => Navigator.pop(context, _selectedDay)
                                : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluePrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: EdgeInsets.symmetric(vertical: w * 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                        ),
                      ),
                      child: Text(
                        _showPicker ? 'Terapkan' : 'Pilih',
                        style: TextStyle(
                          fontSize: (w * 0.035).clamp(12.0, 15.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Page 1: Kalender ──
  Widget _buildCalendarPage(double w) {
    return KeyedSubtree(
      key: const ValueKey('calendar'),
      child: TableCalendar(
        key: ValueKey('cal-${_focusedDay.year}-${_focusedDay.month}'),
        firstDay: widget.firstDate,
        lastDay: widget.lastDate,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        enabledDayPredicate: _isSelectable,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        locale: 'id_ID',
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (context, day) {
            return GestureDetector(
              onTap: _openPicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _showPicker
                          ? AppColors.bluePrimary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_monthNames[_focusedDay.month - 1]} ${_focusedDay.year}',
                      style: TextStyle(
                        fontSize: (w * 0.04).clamp(14.0, 17.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.bluePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.bluePrimary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.bluePrimary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: (w * 0.032).clamp(11.0, 13.0),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
          weekendStyle: TextStyle(
            fontSize: (w * 0.032).clamp(11.0, 13.0),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: AppColors.bluePrimary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.bluePrimary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.bluePrimary,
            fontWeight: FontWeight.w700,
          ),
          disabledTextStyle: const TextStyle(color: Colors.transparent),
          disabledDecoration: const BoxDecoration(shape: BoxShape.circle),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!_isSelectable(selectedDay)) return;
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = focusedDay);
        },
      ),
    );
  }

  // ── Page 2: Drum Picker Bulan + Tahun ──
  Widget _buildPickerPage(double w) {
    const itemHeight = 44.0;
    const visibleItems = 5;
    const pickerHeight = itemHeight * visibleItems;

    final minMonth = _tempYear == widget.firstDate.year
        ? widget.firstDate.month
        : 1;

    final maxMonth = _tempYear == widget.lastDate.year
        ? widget.lastDate.month
        : 12;

    return KeyedSubtree(
      key: const ValueKey('picker'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header page picker
          Padding(
            padding: EdgeInsets.only(bottom: w * 0.04),
            child: Text(
              'Pilih Bulan & Tahun',
              style: TextStyle(
                fontSize: (w * 0.04).clamp(14.0, 17.0),
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          // Label kolom
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'Bulan',
                    style: TextStyle(
                      fontSize: (w * 0.031).clamp(11.0, 13.0),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 1),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Tahun',
                    style: TextStyle(
                      fontSize: (w * 0.031).clamp(11.0, 13.0),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: w * 0.02),

          // Drum picker
          SizedBox(
            height: pickerHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight baris tengah
                Positioned(
                  top: itemHeight * 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: itemHeight,
                    decoration: BoxDecoration(
                      color: AppColors.bluePrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(w * 0.02),
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: AppColors.bluePrimary.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    // ── Kolom Bulan ──
                    Expanded(
                      flex: 3,
                      child: ListWheelScrollView.useDelegate(
                        controller: _monthScrollCtrl,
                        itemExtent: itemHeight,
                        perspective: 0.002,
                        diameterRatio: 4.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _tempMonth = minMonth + index;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: maxMonth - minMonth + 1,
                          builder: (context, index) {
                            final month = minMonth + index;
                            final isSelected = _tempMonth == month;

                            return Center(
                              child: Text(
                                _monthNames[month - 1],
                                style: TextStyle(
                                  fontSize: (w * 0.037).clamp(13.0, 16.0),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.bluePrimary
                                      : Colors.grey.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      height: pickerHeight * 0.5,
                      color: Colors.grey.shade200,
                    ),

                    // ── Kolom Tahun ──
                    Expanded(
                      flex: 2,
                      child: ListWheelScrollView.useDelegate(
                        controller: _yearScrollCtrl,
                        itemExtent: itemHeight,
                        perspective: 0.002,
                        diameterRatio: 4.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _tempYear = _validYears[index];

                            final minMonth = _tempYear == widget.firstDate.year
                                ? widget.firstDate.month
                                : 1;

                            final maxMonth = _tempYear == widget.lastDate.year
                                ? widget.lastDate.month
                                : 12;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_monthScrollCtrl.hasClients) {
                                _monthScrollCtrl.jumpToItem(0);
                              }
                            });

                            if (_tempMonth > maxMonth) {
                              _tempMonth = maxMonth;
                              _monthScrollCtrl.jumpToItem(maxMonth - minMonth);
                            }
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _validYears.length,
                          builder: (context, index) {
                            final year = _validYears[index];
                            final isSelected = _tempYear == year;
                            return Center(
                              child: Text(
                                '$year',
                                style: TextStyle(
                                  fontSize: (w * 0.037).clamp(13.0, 16.0),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.bluePrimary
                                      : Colors.grey.shade700,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
