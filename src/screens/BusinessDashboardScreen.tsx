import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useState } from 'react';
import { SafeAreaView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import Card from '../components/Card';
import GradientBackground from '../components/GradientBackground';
import MonthSelector from '../components/MonthSelector';
import { businesses } from '../constants/businesses';
import { theme } from '../theme/theme';
import { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'BusinessDashboard'>;

export default function BusinessDashboardScreen({ navigation, route }: Props) {
  const business = businesses.find((item) => item.id === route.params.businessId);
  const today = new Date();
  const [month, setMonth] = useState(today.getMonth());
  const [year, setYear] = useState(today.getFullYear());

  if (!business) {
    return null;
  }

  return (
    <GradientBackground>
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.container}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.back}>‹ My Businesses</Text>
          </TouchableOpacity>

          <Text style={styles.title}>{business.name}</Text>
          <Text style={styles.subtitle}>{business.address}</Text>

          <Card>
            <MonthSelector month={month} year={year} onMonthChange={setMonth} onYearChange={setYear} />
          </Card>

          <View style={styles.tiles}>
            <Card
              onPress={() => navigation.navigate('Salary', { businessId: business.id, month, year })}
              style={styles.tile}
            >
              <Text style={styles.tileIcon}>💰</Text>
              <Text style={styles.tileTitle}>Salary</Text>
              <Text style={styles.tileSubtitle}>Track employee pay</Text>
            </Card>

            <Card
              onPress={() => navigation.navigate('Expense', { businessId: business.id, month, year })}
              style={styles.tile}
            >
              <Text style={styles.tileIcon}>🧾</Text>
              <Text style={styles.tileTitle}>Expenses</Text>
              <Text style={styles.tileSubtitle}>Calculate monthly costs</Text>
            </Card>
          </View>
        </View>
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
    marginBottom: 6,
  },
  title: {
    color: theme.colors.text,
    fontSize: theme.typography.title,
    fontWeight: '800',
  },
  subtitle: {
    color: theme.colors.textMuted,
    fontSize: theme.typography.subtitle,
    marginBottom: theme.spacing.sm,
  },
  tiles: {
    gap: theme.spacing.md,
  },
  tile: {
    minHeight: 150,
    justifyContent: 'center',
  },
  tileIcon: {
    fontSize: 36,
    marginBottom: 6,
  },
  tileTitle: {
    color: theme.colors.text,
    fontSize: theme.typography.heading,
    fontWeight: '800',
  },
  tileSubtitle: {
    color: theme.colors.textMuted,
    marginTop: 2,
  },
});
