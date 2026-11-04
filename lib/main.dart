import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProductManagerApp());
}

class ProductManagerApp extends StatelessWidget {
  const ProductManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autumn Product Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const ProductHomePage(),
    );
  }
}

class ProductHomePage extends StatefulWidget {
  const ProductHomePage({super.key});

  @override
  State<ProductHomePage> createState() => _ProductHomePageState();
}

class _ProductHomePageState extends State<ProductHomePage> {
  final CollectionReference<Map<String, dynamic>> products =
      FirebaseFirestore.instance.collection('products');

  final TextEditingController searchController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  String searchText = '';
  String? filterError;

  @override
  void dispose() {
    searchController.dispose();
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  double? readBound(String value) {
    if (value.trim().isEmpty) return null;
    final number = double.tryParse(value.trim());
    if (number == null || !number.isFinite || number < 0) {
      throw const FormatException(
        'Enter a valid non-negative number for each price limit.',
      );
    }
    return number;
  }

  void applyFilters() {
    try {
      final min = readBound(minController.text);
      final max = readBound(maxController.text);
      if (min != null && max != null && min > max) {
        throw const FormatException(
          'Minimum price cannot be greater than maximum price.',
        );
      }
      setState(() => filterError = null);
    } on FormatException catch (error) {
      setState(() => filterError = error.message);
    }
  }

  void resetFilters() {
    searchController.clear();
    minController.clear();
    maxController.clear();
    setState(() {
      searchText = '';
      filterError = null;
    });
  }

  Future<void> showProductDialog({
    String? documentId,
    String? initialName,
    double? initialPrice,
  }) async {
    final nameController = TextEditingController(text: initialName ?? '');
    final priceController = TextEditingController(
      text: initialPrice == null ? '' : initialPrice.toString(),
    );
    String? dialogError;
    final isEditing = documentId != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit product' : 'Add product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'Example: 12.50',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final price =
                              double.tryParse(priceController.text.trim());

                          if (name.isEmpty) {
                            setDialogState(() =>
                                dialogError = 'Product name cannot be empty.');
                            return;
                          }
                          if (price == null ||
                              !price.isFinite ||
                              price < 0) {
                            setDialogState(() => dialogError =
                                'Enter a valid non-negative price.');
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            dialogError = null;
                          });

                          try {
                            final data = <String, dynamic>{
                              'name': name,
                              'price': price,
                            };
                            if (isEditing) {
                              await products.doc(documentId).update(data);
                            } else {
                              await products.add(data);
                            }
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing
                                      ? 'Product updated.'
                                      : 'Product added.'),
                                ),
                              );
                            }
                          } on FirebaseException catch (error) {
                            setDialogState(() {
                              saving = false;
                              dialogError =
                                  'Firebase error: ${error.message ?? error.code}';
                            });
                          } catch (error) {
                            setDialogState(() {
                              saving = false;
                              dialogError = 'Could not save product: $error';
                            });
                          }
                        },
                  child: Text(saving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
  }

  Future<void> deleteProduct(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await products.doc(id).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted.')),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${error.message ?? error.code}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autumn Product Manager'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search products',
                      hintText: 'Search by name',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();
                          setState(() => searchText = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        setState(() => searchText = value.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          decoration: const InputDecoration(
                            labelText: 'Minimum price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          decoration: const InputDecoration(
                            labelText: 'Maximum price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => applyFilters(),
                        ),
                      ),
                    ],
                  ),
                  if (filterError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          filterError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: resetFilters,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset filters'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: products.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not load products.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No products in the collection yet.'),
                    );
                  }

                  double? minPrice;
                  double? maxPrice;
                  try {
                    minPrice = readBound(minController.text);
                    maxPrice = readBound(maxController.text);
                  } on FormatException {
                    minPrice = null;
                    maxPrice = null;
                  }

                  final filtered = docs.where((doc) {
                    final data = doc.data();
                    final name = (data['name'] ?? '').toString();
                    final rawPrice = data['price'];
                    final price = rawPrice is num ? rawPrice.toDouble() : null;

                    if (!name.toLowerCase().contains(searchText)) return false;
                    if (price == null) return false;
                    if (minPrice != null && price < minPrice) return false;
                    if (maxPrice != null && price > maxPrice) return false;
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final data = doc.data();
                      final name = (data['name'] ?? '').toString();
                      final rawPrice = data['price'];
                      final price = rawPrice is num ? rawPrice.toDouble() : 0.0;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(name.isEmpty
                                ? '?'
                                : name.characters.first.toUpperCase()),
                          ),
                          title: Text(name),
                          subtitle: Text(
                            '\$${price.toStringAsFixed(2)}  •  ID: ${doc.id}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                showProductDialog(
                                  documentId: doc.id,
                                  initialName: name,
                                  initialPrice: price,
                                );
                              } else if (value == 'delete') {
                                deleteProduct(doc.id, name);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
