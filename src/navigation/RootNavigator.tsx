import { createNativeStackNavigator } from '@react-navigation/native-stack';
import BusinessListScreen from '../screens/BusinessListScreen';
import BusinessDashboardScreen from '../screens/BusinessDashboardScreen';
import SalaryScreen from '../screens/SalaryScreen';
import ExpenseScreen from '../screens/ExpenseScreen';
import { RootStackParamList } from '../types';
import { theme } from '../theme/theme';

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function RootNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: theme.colors.background },
      }}
    >
      <Stack.Screen name="BusinessList" component={BusinessListScreen} />
      <Stack.Screen name="BusinessDashboard" component={BusinessDashboardScreen} />
      <Stack.Screen name="Salary" component={SalaryScreen} />
      <Stack.Screen name="Expense" component={ExpenseScreen} />
    </Stack.Navigator>
  );
}
