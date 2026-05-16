import { NativeStackScreenProps } from '@react-navigation/native-stack';
import {
  Alert,
  FlatList,
  Modal,
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { useEffect, useMemo, useState } from 'react';
import Card from '../components/Card';
import GradientBackground from '../components/GradientBackground';
import MonthSelector from '../components/MonthSelector';
import { businesses } from '../constants/businesses';
import { getExpenses, saveExpenses } from '../storage/storage';
import { theme } from '../theme/theme';
import { ExpenseEntry, MONTHS, RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'Expense'>;

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

export default function ExpenseScreen({ navigation, route }: Props) {
  const business = businesses.find((item) => item.id === route.params.businessId);
  const [month, setMonth] = useState(route.params.month);
  const [year, setYear] = useState(route.params.year);
  const [entries, setEntries] = useState<ExpenseEntry[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [category, setCategory] = useState('');

  useEffect(() => {
    if (!business) {
      return;
    }

    getExpenses(business.id, year, month).then(setEntries);
  }, [business, month, year]);

  const footerTotal = useMemo(() => entries.reduce((sum, entry) => sum + entry.amount, 0), [entries]);

  const closeModal = () => {
    setModalVisible(false);
    setEditingId(null);
    setDescription('');
    setAmount('');
    setCategory('');
  };

  const persist = async (nextEntries: ExpenseEntry[]) => {
    if (!business) {
      return;
    }

    setEntries(nextEntries);
    await saveExpenses(business.id, year, month, nextEntries);
  };

  const onSave = async () => {
    const parsedAmount = Number(amount);

    if (!description.trim() || !Number.isFinite(parsedAmount)) {
      Alert.alert('Missing details', 'Please add a description and amount.');
      return;
    }

    const entry: ExpenseEntry = {
      id: editingId ?? `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
      description: description.trim(),
      amount: parsedAmount,
      category: category.trim() || undefined,
      createdAt: new Date().toISOString(),
    };

    const nextEntries = editingId
      ? entries.map((item) => (item.id === editingId ? entry : item))
      : [entry, ...entries];

    await persist(nextEntries);
    closeModal();
  };

  const onEdit = (entry: ExpenseEntry) => {
    setEditingId(entry.id);
    setDescription(entry.description);
    setAmount(String(entry.amount));
    setCategory(entry.category ?? '');
    setModalVisible(true);
  };

  const onDelete = (entry: ExpenseEntry) => {
    Alert.alert('Delete expense', `Delete ${entry.description}?`, [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Delete',
        style: 'destructive',
        onPress: async () => {
          const nextEntries = entries.filter((item) => item.id !== entry.id);
          await persist(nextEntries);
        },
      },
    ]);
  };

  if (!business) {
    return null;
  }

  return (
    <GradientBackground>
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.container}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.back}>‹ {business.name}</Text>
          </TouchableOpacity>

          <Text style={styles.title}>Expenses</Text>
          <Text style={styles.subtitle}>
            {business.name} • {MONTHS[month]} {year}
          </Text>

          <Card>
            <MonthSelector month={month} year={year} onMonthChange={setMonth} onYearChange={setYear} />
          </Card>

          <TouchableOpacity style={styles.primaryButton} onPress={() => setModalVisible(true)}>
            <Text style={styles.primaryButtonText}>+ Add Expense</Text>
          </TouchableOpacity>

          <FlatList
            data={entries}
            keyExtractor={(item) => item.id}
            contentContainerStyle={styles.list}
            renderItem={({ item }) => (
              <Card style={styles.entryCard}>
                <TouchableOpacity onPress={() => onEdit(item)} onLongPress={() => onDelete(item)}>
                  <Text style={styles.entryName}>{item.description}</Text>
                  <Text style={styles.entryMeta}>{item.category ? `Category: ${item.category}` : 'Category: -'}</Text>
                  <Text style={styles.entryTotal}>{currency.format(item.amount)}</Text>
                </TouchableOpacity>
              </Card>
            )}
            ListEmptyComponent={<Text style={styles.empty}>No expenses yet for this month.</Text>}
          />

          <Card>
            <Text style={styles.footerLabel}>
              Total Expenses for {MONTHS[month]} {year}: {currency.format(footerTotal)}
            </Text>
          </Card>

          {/* TODO: Add GST/HST reporting, multi-user sync, and PDF export in future iterations. */}
        </View>

        <Modal visible={modalVisible} transparent animationType="slide" onRequestClose={closeModal}>
          <View style={styles.modalOverlay}>
            <Card style={styles.modalCard}>
              <Text style={styles.modalTitle}>{editingId ? 'Edit Expense' : 'Add Expense'}</Text>

              <TextInput
                placeholder="Expense name / description"
                placeholderTextColor={theme.colors.textMuted}
                value={description}
                onChangeText={setDescription}
                style={styles.input}
              />

              <TextInput
                placeholder="Amount"
                placeholderTextColor={theme.colors.textMuted}
                value={amount}
                onChangeText={setAmount}
                keyboardType="decimal-pad"
                style={styles.input}
              />

              <TextInput
                placeholder="Category (optional)"
                placeholderTextColor={theme.colors.textMuted}
                value={category}
                onChangeText={setCategory}
                style={styles.input}
              />

              <View style={styles.modalActions}>
                <TouchableOpacity style={styles.secondaryButton} onPress={closeModal}>
                  <Text style={styles.secondaryButtonText}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.primaryButton} onPress={onSave}>
                  <Text style={styles.primaryButtonText}>Save</Text>
                </TouchableOpacity>
              </View>
            </Card>
          </View>
        </Modal>
      </SafeAreaView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
  container: {
    flex: 1,
    padding: theme.spacing.lg,
    gap: theme.spacing.md,
  },
  back: {
    color: theme.colors.accent,
    fontWeight: '700',
  },
  title: {
    color: theme.colors.text,
    fontSize: theme.typography.title,
    fontWeight: '800',
  },
  subtitle: {
    color: theme.colors.textMuted,
  },
  primaryButton: {
    backgroundColor: theme.colors.accent,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 12,
    borderRadius: theme.radius.md,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: theme.colors.background,
    fontWeight: '800',
  },
  list: {
    gap: theme.spacing.sm,
    paddingBottom: theme.spacing.md,
  },
  entryCard: {
    paddingVertical: theme.spacing.sm,
  },
  entryName: {
    color: theme.colors.text,
    fontWeight: '700',
    fontSize: theme.typography.body,
  },
  entryMeta: {
    color: theme.colors.textMuted,
    marginTop: 2,
  },
  entryTotal: {
    color: theme.colors.success,
    marginTop: 4,
    fontWeight: '700',
  },
  empty: {
    color: theme.colors.textMuted,
    textAlign: 'center',
    marginTop: theme.spacing.sm,
  },
  footerLabel: {
    color: theme.colors.text,
    fontWeight: '700',
    fontSize: theme.typography.body,
  },
  modalOverlay: {
    flex: 1,
    justifyContent: 'flex-end',
    backgroundColor: 'rgba(2, 6, 23, 0.7)',
    padding: theme.spacing.lg,
  },
  modalCard: {
    gap: theme.spacing.sm,
  },
  modalTitle: {
    color: theme.colors.text,
    fontWeight: '800',
    fontSize: theme.typography.heading,
    marginBottom: 4,
  },
  input: {
    borderWidth: 1,
    borderColor: theme.colors.cardBorder,
    borderRadius: theme.radius.md,
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 10,
    color: theme.colors.text,
    backgroundColor: 'rgba(15, 23, 42, 0.75)',
  },
  modalActions: {
    flexDirection: 'row',
    gap: theme.spacing.sm,
    justifyContent: 'flex-end',
    marginTop: 2,
  },
  secondaryButton: {
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 12,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    borderColor: theme.colors.cardBorder,
    backgroundColor: 'rgba(15, 23, 42, 0.65)',
  },
  secondaryButtonText: {
    color: theme.colors.text,
    fontWeight: '700',
  },
});
