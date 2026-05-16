export type Business = {
  id: string;
  name: string;
  address: string;
  type: string;
  icon: string;
};

export type SalaryEntry = {
  id: string;
  name: string;
  hours: number;
  payRate: number;
  createdAt: string;
};

export type ExpenseEntry = {
  id: string;
  description: string;
  amount: number;
  category?: string;
  createdAt: string;
};

export type RootStackParamList = {
  BusinessList: undefined;
  BusinessDashboard: { businessId: string };
  Salary: { businessId: string; month: number; year: number };
  Expense: { businessId: string; month: number; year: number };
};

export const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
