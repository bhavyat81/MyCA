import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import Card from '../components/Card';
import GradientBackground from '../components/GradientBackground';
import { businesses } from '../constants/businesses';
import { theme } from '../theme/theme';
import { RootStackParamList } from '../types';

type Props = NativeStackScreenProps<RootStackParamList, 'BusinessList'>;

export default function BusinessListScreen({ navigation }: Props) {
  return (
    <GradientBackground>
      <SafeAreaView style={styles.safeArea}>
        <ScrollView contentContainerStyle={styles.container}>
          <Text style={styles.title}>My Businesses</Text>
          <Text style={styles.subtitle}>Select a business to manage</Text>

          <View style={styles.list}>
            {businesses.map((business) => (
              <Card
                key={business.id}
                onPress={() => navigation.navigate('BusinessDashboard', { businessId: business.id })}
                style={styles.card}
              >
                <View style={styles.row}>
                  <Text style={styles.icon}>{business.icon}</Text>
                  <View style={styles.content}>
                    <Text style={styles.businessName}>{business.name}</Text>
                    <Text style={styles.address}>{business.address}</Text>
                    <View style={styles.tag}>
                      <Text style={styles.tagText}>{business.type}</Text>
                    </View>
                  </View>
                  <Text style={styles.arrow}>›</Text>
                </View>
              </Card>
            ))}
          </View>
        </ScrollView>
      </SafeAreaView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  safeArea: { flex: 1 },
  container: {
    padding: theme.spacing.lg,
    paddingTop: theme.spacing.xl,
    gap: theme.spacing.md,
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
  list: {
    gap: theme.spacing.md,
  },
  card: {
    backgroundColor: 'rgba(30, 41, 59, 0.55)',
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: theme.spacing.md,
  },
  icon: {
    fontSize: 30,
  },
  content: {
    flex: 1,
    gap: 4,
  },
  businessName: {
    color: theme.colors.text,
    fontSize: 20,
    fontWeight: '800',
  },
  address: {
    color: theme.colors.textMuted,
    fontSize: theme.typography.body,
  },
  tag: {
    alignSelf: 'flex-start',
    marginTop: 4,
    backgroundColor: 'rgba(34, 211, 238, 0.2)',
    borderWidth: 1,
    borderColor: 'rgba(34, 211, 238, 0.4)',
    borderRadius: 14,
    paddingVertical: 4,
    paddingHorizontal: 10,
  },
  tagText: {
    color: theme.colors.accent,
    fontWeight: '700',
    fontSize: theme.typography.small,
  },
  arrow: {
    color: theme.colors.accent,
    fontSize: 28,
    fontWeight: '600',
  },
});
