import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/calendar_date_picker.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:pocketree/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:pocketree/features/reports/presentation/bloc/reports_event.dart';
import 'package:pocketree/features/reports/presentation/bloc/reports_state.dart';
import 'package:pocketree/features/reports/presentation/widgets/accounts_tab.dart';
import 'package:pocketree/features/reports/presentation/widgets/categories_tab.dart';
import 'package:pocketree/features/reports/presentation/widgets/overview_tab.dart';
import 'package:pocketree/features/reports/presentation/widgets/reports_filter_sheet.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _tabs = ['Overview', 'Categories', 'Accounts'];

  int _selectedTab = 0;
  late DateTimeRange _selectedRange;

  int? _accountId;
  String _type = 'expense';
  String _groupBy = 'day';
  int _topN = 10;
  int _limit = 5;

  List<Account>? _accounts;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    _dispatchLoad();
    _loadAccounts();
  }

  void _dispatchLoad() {
    context.read<ReportsBloc>().add(
      ReportsDataRequested(
        startDate: _selectedRange.start,
        endDate: _selectedRange.end,
        accountId: _accountId,
        groupBy: _groupBy,
        type: _type,
        topN: _topN,
        limit: _limit,
      ),
    );
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final result = await showCalendarRangePicker(
      context,
      initialRange: _selectedRange,
      maxDate: DateTime(now.year, now.month + 1, 0),
    );
    if (result == null || !mounted) return;
    setState(() => _selectedRange = result);
    _dispatchLoad();
  }

  Future<void> _loadAccounts() async {
    final result = await sl<GetAccountsUseCase>()();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _accounts = const []),
      (accounts) => setState(() => _accounts = accounts),
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<ReportsFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReportsFilterSheet(
        initial: ReportsFilterResult(
          accountId: _accountId,
          type: _type,
          groupBy: _groupBy,
          topN: _topN,
          limit: _limit,
        ),
        accounts: _accounts ?? const [],
        isLoadingAccounts: _accounts == null,
      ),
    );
    if (result == null || !mounted) return;
    final changed = result.accountId != _accountId ||
        result.type != _type ||
        result.groupBy != _groupBy ||
        result.topN != _topN ||
        result.limit != _limit;
    if (!changed) return;
    setState(() {
      _accountId = result.accountId;
      _type = result.type;
      _groupBy = result.groupBy;
      _topN = result.topN;
      _limit = result.limit;
    });
    _dispatchLoad();
  }

  bool get _hasActiveFilters =>
      _accountId != null ||
      _type != 'expense' ||
      _groupBy != 'day' ||
      _topN != 10 ||
      _limit != 5;

  String get _rangeLabel {
    final start = _selectedRange.start;
    final end = _selectedRange.end;
    final isFullMonth =
        start.day == 1 &&
        end.year == start.year &&
        end.month == start.month &&
        end.day == DateTime(start.year, start.month + 1, 0).day;
    final String datePart;
    if (isFullMonth) {
      datePart = DateFormat('MMMM yyyy').format(start);
    } else {
      final sameYear = start.year == end.year;
      final startFmt = DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy');
      final endFmt = DateFormat('d MMM yyyy');
      datePart = '${startFmt.format(start)} – ${endFmt.format(end)}';
    }
    final accountName = _accountId == null
        ? null
        : _accounts
            ?.cast<Account?>()
            .firstWhere((a) => a?.id == _accountId, orElse: () => null)
            ?.name;
    return accountName == null ? datePart : '$datePart · $accountName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBeige,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryForest,
                backgroundColor: AppColors.white,
                onRefresh: () {
                  final event = ReportsDataRefreshed();
                  context.read<ReportsBloc>().add(event);
                  return event.completer.future;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading || state is ReportsInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryForest),
            ),
          );
        }
        if (state is ReportsError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.brownMocha,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _dispatchLoad,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ReportsLoaded) {
          return _buildTab(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTab(ReportsLoaded state) {
    final data = state.data;
    switch (_selectedTab) {
      case 0:
        return OverviewTab(
          data: data,
          selectedType: state.type,
          groupBy: state.groupBy,
        );
      case 1:
        return CategoriesTab(breakdown: data.categoryBreakdown);
      case 2:
        return AccountsTab(breakdown: data.accountBreakdown);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _rangeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.brownMocha,
                  ),
                ),
              ],
            ),
          ),
          _headerIconButton(
            icon: Icons.tune_rounded,
            onTap: _openFilterSheet,
            showBadge: _hasActiveFilters,
          ),
          const SizedBox(width: 8),
          _headerIconButton(
            icon: Icons.calendar_today_rounded,
            onTap: _pickRange,
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.neutralSand,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primaryForest,
              ),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.errorRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.neutralSand,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final selected = i == _selectedTab;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.brownEspresso
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.white : AppColors.brownMocha,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
