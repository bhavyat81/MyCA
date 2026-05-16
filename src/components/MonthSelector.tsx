import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { MONTHS } from '../types';
import { theme } from '../theme/theme';

type Props = {
  month: number;
  year: number;
  onMonthChange: (month: number) => void;
  onYearChange: (year: number) => void;
};

export default function MonthSelector({ month, year, onMonthChange, onYearChange }: Props) {
  return (
    <View style={styles.container}>
      <View style={styles.yearRow}>
        <TouchableOpacity onPress={() => onYearChange(year - 1)} style={styles.yearButton}>
          <Text style={styles.yearButtonText}>‹</Text>
        </TouchableOpacity>
        <Text style={styles.yearText}>{year}</Text>
        <TouchableOpacity onPress={() => onYearChange(year + 1)} style={styles.yearButton}>
          <Text style={styles.yearButtonText}>›</Text>
        </TouchableOpacity>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.monthRow}>
        {MONTHS.map((label, index) => {
          const selected = index === month;
          return (
            <TouchableOpacity
              key={label}
              onPress={() => onMonthChange(index)}
              style={[styles.monthChip, selected && styles.monthChipSelected]}
            >
              <Text style={[styles.monthLabel, selected && styles.monthLabelSelected]}>{label}</Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: theme.spacing.sm,
  },
  yearRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: theme.spacing.sm,
  },
  yearButton: {
    width: 34,
    height: 34,
    borderRadius: 17,
    alignItems: 'center',
    justifyContent: 'center',
    borderColor: theme.colors.cardBorder,
    borderWidth: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.8)',
  },
  yearButtonText: {
    color: theme.colors.accent,
    fontSize: 20,
    fontWeight: '700',
    marginTop: -2,
  },
  yearText: {
    color: theme.colors.text,
    fontSize: theme.typography.heading,
    fontWeight: '700',
    minWidth: 80,
    textAlign: 'center',
  },
  monthRow: {
    gap: theme.spacing.sm,
    paddingVertical: 2,
  },
  monthChip: {
    paddingHorizontal: theme.spacing.md,
    paddingVertical: 8,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: theme.colors.cardBorder,
    backgroundColor: 'rgba(15, 23, 42, 0.7)',
  },
  monthChipSelected: {
    backgroundColor: theme.colors.accent,
    borderColor: theme.colors.accent,
  },
  monthLabel: {
    color: theme.colors.textMuted,
    fontWeight: '600',
  },
  monthLabelSelected: {
    color: theme.colors.background,
    fontWeight: '700',
  },
});
