// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Инициализация Firebase Admin
admin.initializeApp();

// Экспорт функций чат-рулетки
export { findMatches, endMatch, saveChat, cleanupOldRecords } from './chatRoulette';
