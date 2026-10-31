import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/assistant/models/ai_action_model.dart';
import 'package:costbook/features/assistant/models/chat_message_model.dart';

void main() {
  const ask = ChatMessageModel(role: ChatMessageModel.user, text: 'รับเคสเข้า 10 ชิ้น');
  const answer = ChatMessageModel(role: ChatMessageModel.assistant, text: 'กดยืนยันด้านล่างได้เลย');
  const note = ChatMessageModel(role: ChatMessageModel.note, text: '[ผู้ใช้กดยืนยันงาน stock_in แล้ว ทำสำเร็จ]');
  const askAgain = ChatMessageModel(role: ChatMessageModel.user, text: 'เหลือกี่ชิ้นแล้ว');

  group('ChatMessageModel.reply', () {
    test('อ่านคำตอบ + งานที่ AI เสนอ', () {
      final reply = ChatMessageModel.reply({
        'reply': ' กดยืนยันได้เลย ',
        'actions': [
          {
            'id': 't1',
            'type': 'stock_in',
            'product_id': 'p1',
            'data': {'quantity': 10},
          },
        ],
      });
      expect([reply.role, reply.text, reply.actions.length], [ChatMessageModel.assistant, 'กดยืนยันได้เลย', 1]);
      expect(reply.actions.first.type, AiActionModel.stockIn);
    });
  });

  group('ChatMessageModel.toApi', () {
    test('ถาม ตอบ ถามต่อ ส่งเป็นข้อความสลับกัน', () {
      expect(ChatMessageModel.toApi([ask, answer, askAgain]), [
        {'role': 'user', 'content': 'รับเคสเข้า 10 ชิ้น'},
        {'role': 'assistant', 'content': 'กดยืนยันด้านล่างได้เลย'},
        {'role': 'user', 'content': 'เหลือกี่ชิ้นแล้ว'},
      ]);
    });

    test('ผลของการกดยืนยัน (note) ส่งไปพร้อมคำถามถัดไป', () {
      final history = ChatMessageModel.toApi([ask, answer, note, askAgain]);
      expect(history.length, 3);
      expect(history.last['content'], '[ผู้ใช้กดยืนยันงาน stock_in แล้ว ทำสำเร็จ]\nเหลือกี่ชิ้นแล้ว');
    });

    test('ถามซ้ำหลังส่งไม่สำเร็จ รวมเป็นข้อความเดียว', () {
      final history = ChatMessageModel.toApi([ask, askAgain]);
      expect(history, [
        {'role': 'user', 'content': 'รับเคสเข้า 10 ชิ้น\nเหลือกี่ชิ้นแล้ว'},
      ]);
    });

    test('คำตอบที่มีแต่งาน (ไม่มีข้อความ) ใส่ข้อความแทน ไม่ส่งข้อความว่าง', () {
      const actionsOnly = ChatMessageModel(role: ChatMessageModel.assistant);
      final history = ChatMessageModel.toApi([ask, actionsOnly, askAgain]);
      expect(history[1]['content'], ChatMessageModel.actionsOnlyText);
    });

    test('ยาวเกิน 40 ข้อความ ตัดอันเก่าทิ้งทีละคู่ ยังเริ่มด้วยคำถาม', () {
      final messages = [
        for (var i = 0; i < 25; i++) ...[ask, answer],
        askAgain,
      ];
      final history = ChatMessageModel.toApi(messages);
      expect(history.length, 39);
      expect(history.first['role'], 'user');
      expect(history.last['content'], 'เหลือกี่ชิ้นแล้ว');
    });
  });
}
