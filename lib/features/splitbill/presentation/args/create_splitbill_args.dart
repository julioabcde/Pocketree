import 'package:pocketree/features/splitbill/presentation/models/split_bill_charge_input.dart';
import 'package:pocketree/features/splitbill/presentation/models/split_bill_item_input.dart';

class CreateSplitbillArgs {
  final List<SplitBillItemInput>? prefillItems;
  final List<SplitBillChargeInput>? prefillCharges;
  final String? source; 

  const CreateSplitbillArgs({
    this.prefillItems,
    this.prefillCharges,
    this.source,
  });
}
