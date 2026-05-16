import AsyncStorage from '@react-native-async-storage/async-storage';
import { ExpenseEntry, SalaryEntry } from '../types';

const monthKey = (month: number) => String(month + 1).padStart(2, '0');

const salaryKey = (businessId: string, year: number, month: number) =>
  `myca:salaries:${businessId}:${year}-${monthKey(month)}`;

const expenseKey = (businessId: string, year: number, month: number) =>
  `myca:expenses:${businessId}:${year}-${monthKey(month)}`;

const safeParse = <T>(value: string | null): T[] => {
  if (!value) {
    return [];
  }

  try {
    return JSON.parse(value) as T[];
  } catch {
    return [];
  }
};

export const getSalaries = async (businessId: string, year: number, month: number): Promise<SalaryEntry[]> => {
  const value = await AsyncStorage.getItem(salaryKey(businessId, year, month));
  return safeParse<SalaryEntry>(value);
};

export const saveSalaries = async (
  businessId: string,
  year: number,
  month: number,
  entries: SalaryEntry[],
): Promise<void> => {
  await AsyncStorage.setItem(salaryKey(businessId, year, month), JSON.stringify(entries));
};

export const getExpenses = async (businessId: string, year: number, month: number): Promise<ExpenseEntry[]> => {
  const value = await AsyncStorage.getItem(expenseKey(businessId, year, month));
  return safeParse<ExpenseEntry>(value);
};

export const saveExpenses = async (
  businessId: string,
  year: number,
  month: number,
  entries: ExpenseEntry[],
): Promise<void> => {
  await AsyncStorage.setItem(expenseKey(businessId, year, month), JSON.stringify(entries));
};
