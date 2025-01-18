import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from matplotlib.font_manager import FontProperties

# 设置中文字体
font = FontProperties(fname=r"C:\Windows\Fonts\msyh.ttc", size=18)  # 增加默认字体大小
plt.rcParams['axes.unicode_minus'] = False
plt.rcParams['figure.figsize'] = [15, 10]

# 创建完整的数据框
df1 = pd.DataFrame({
    'table_name': [
        'task_assignments', 'progress_records', 'student_stage_scores', 'users', 'users',
        'defense_committee', 'translation_reviews', 'task_assignments', 'defense_arrangements',
        'supervisors', 'users', 'defense_scores', 'literature_reviews', 'system_messages',
        'midterm_reports', 'system_logs', 'next_stage_queue', 'topic_selections',
        'thesis_review_details', 'topic_selections', 'system_messages', 'topic_selections',
        'literature_reviews', 'task_assignments', 'topics', 'defense_committee',
        'thesis_reviews_assignment', 'thesis_submissions', 'progress_stages'
    ],
    'index_name': [
        'teacher_id', 'unique_student_stage', 'student_id', 'idx_username_status', 'idx_role',
        'member1_id', 'idx_student_status', 'student_id', 'unique_student_defense',
        'idx_department', 'idx_staff_id', 'unique_defense_teacher', 'unique_student_version',
        'created_by', 'idx_student_status', 'idx_user_action_time', 'processed',
        'idx_topic_status', 'assignment_id', 'idx_student_topic_status',
        'idx_message_status_priority', 'topic_selections_ibfk_3', 'idx_teacher', 'topic_id',
        'idx_teacher_status', 'chairman_id', 'reviewer_id', 'student_id', 'sequence'
    ],
    'time_without_index': [
        234.1380, 185.7540, 125.1560, 107.9130, 261.7610, 129.8670, 148.9890, 116.1960,
        81.3230, 94.0040, 159.4680, 104.8810, 94.9570, 103.4960, 92.8600, 81.8300,
        84.6210, 129.6260, 79.8550, 105.7320, 71.1380, 88.5730, 77.1460, 75.8500,
        106.2030, 87.1390, 137.7550, 88.6300, 93.7640
    ],
    'time_with_index': [
        109.1130, 95.9130, 85.6120, 75.7350, 185.4190, 98.1450, 115.3940, 95.6750,
        70.1660, 80.7290, 137.8470, 95.1080, 87.3250, 94.5390, 86.5620, 79.3970,
        83.2150, 134.0600, 103.6060, 143.0390, 98.6640, 122.6760, 108.5430, 107.6600,
        158.5360, 131.3590, 278.2650, 181.0380, 252.9270
    ],
    'performance_improvement': [
        2.15, 1.94, 1.46, 1.42, 1.41, 1.32, 1.29, 1.21, 1.16, 1.16, 1.16, 1.10,
        1.09, 1.09, 1.07, 1.03, 1.02, 0.97, 0.77, 0.74, 0.72, 0.72, 0.71, 0.70,
        0.67, 0.66, 0.50, 0.49, 0.37
    ],
    'total_rows': [
        13, 7212, 5978, 2000, 2000, 2, 4, 13, 3, 30, 2000, 15, 4, 7, 4, 1403, 0,
        159, 12, 159, 7, 159, 4, 13, 2000, 2, 12, 4, 9
    ]
})

# 创建行数减少数据框
reduction_data = pd.DataFrame({
    'table_name': [
        'thesis_submissions', 'topics', 'system_logs', 'defense_arrangements',
        'literature_reviews', 'midterm_reports', 'supervisors', 'system_messages',
        'task_assignments', 'thesis_reviews_assignment', 'topic_selections',
        'translation_reviews', 'thesis_review_details', 'defense_committee',
        'defense_scores', 'topic_selections', 'literature_reviews', 'defense_committee',
        'task_assignments', 'system_messages', 'task_assignments', 'topic_selections',
        'users', 'progress_records', 'users', 'student_stage_scores', 'users',
        'progress_stages'
    ],
    'rows_before': [4, 2000, 1403, 3, 4, 4, 30, 7, 13, 12, 159, 4, 12, 2, 15, 159,
                    4, 2, 13, 7, 13, 159, 2000, 7212, 2000, 5978, 2000, 9],
    'rows_after': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                   0, 0, 1, 1, 8, 1000, 6],
    'reduction_percentage': [
        100.00, 100.00, 100.00, 100.00, 100.00, 100.00, 100.00, 100.00, 100.00,
        100.00, 100.00, 100.00, 100.00, 100.00, 100.00, 100.00, 100.00, 100.00,
        100.00, 100.00, 100.00, 100.00, 100.00, 99.99, 99.95, 99.87, 50.00, 33.33
    ]
})

# 创建综合评分数据框
composite_score_data = pd.DataFrame({
    'table_name': [
        'progress_records', 'student_stage_scores', 'users', 'users', 'users',
        'system_logs', 'task_assignments', 'topics', 'topic_selections', 'supervisors',
        'topic_selections', 'topic_selections', 'task_assignments', 'defense_scores',
        'system_messages', 'thesis_review_details', 'translation_reviews',
        'task_assignments', 'literature_reviews', 'midterm_reports', 'system_messages',
        'defense_arrangements', 'thesis_reviews_assignment', 'literature_reviews',
        'defense_committee', 'progress_stages', 'thesis_submissions', 'defense_committee'
    ],
    'composite_score': [
        7.47, 5.52, 4.70, 4.66, 3.82, 3.24, 2.39, 2.21, 2.13, 1.72, 1.63, 1.59,
        1.35, 1.30, 0.93, 0.83, 0.78, 0.78, 0.65, 0.65, 0.61, 0.55, 0.53, 0.43,
        0.40, 0.35, 0.29, 0.20
    ]
})

# 1. 性能提升与数据量的散点图
plt.figure(figsize=(20, 12))
plt.scatter(df1['total_rows'], df1['performance_improvement'], alpha=0.6, s=200)  # 增加散点大小
for i, txt in enumerate(df1['table_name']):
    plt.annotate(f"{txt}\n({df1['index_name'].iloc[i]})", 
                (df1['total_rows'].iloc[i], df1['performance_improvement'].iloc[i]),
                fontsize=16,  # 增加注释文字大小
                fontproperties=font)
plt.xscale('log')
plt.xlabel('Data Volume (Rows)', fontsize=14)
plt.ylabel('Performance Improvement', fontsize=14)
plt.xticks(fontsize=18)
plt.yticks(fontsize=18)
plt.grid(True)
plt.show()

# 2. 查询时间对比图（前15个表）
plt.figure(figsize=(20, 12))
top_15 = df1.nlargest(15, 'time_without_index')
x = range(len(top_15))
width = 0.35
plt.bar(x, top_15['time_without_index'], width, label='Without Index')
plt.bar([i + width for i in x], top_15['time_with_index'], width, label='With Index')
plt.xticks([i + width/2 for i in x], top_15['table_name'], rotation=45, ha='right', 
           fontproperties=font, fontsize=18)
plt.yticks(fontsize=18)
plt.legend(prop=font, fontsize=18)
plt.tight_layout()
plt.show()

# 3. 行数减少百分比图
plt.figure(figsize=(20, 12))
reduction_sorted = reduction_data.sort_values('reduction_percentage', ascending=True)
plt.barh(range(len(reduction_sorted)), reduction_sorted['reduction_percentage'])
plt.yticks(range(len(reduction_sorted)), reduction_sorted['table_name'], 
           fontproperties=font, fontsize=18)
plt.xticks(fontsize=18)
plt.tight_layout()
plt.show()

# 4. 综合评分排名（Top 15）
plt.figure(figsize=(20, 12))
top_15_score = composite_score_data.nlargest(15, 'composite_score')
plt.barh(range(len(top_15_score)), top_15_score['composite_score'])
plt.yticks(range(len(top_15_score)), top_15_score['table_name'], 
           fontproperties=font, fontsize=18)
plt.xticks(fontsize=18)
plt.tight_layout()
plt.show()

# 5. 性能分布统计
plt.figure(figsize=(15, 10))
bins = [0, 0.5, 1.0, 1.5, 2.0, float('inf')]
labels = ['Very Poor(≤0.5)', 'Poor(0.5-1.0)', 'Average(1.0-1.5)', 'Good(1.5-2.0)', 'Excellent(>2.0)']
df1['performance_category'] = pd.cut(df1['performance_improvement'], bins=bins, labels=labels)
category_counts = df1['performance_category'].value_counts()
plt.bar(range(len(category_counts)), category_counts.values)
plt.xticks(range(len(category_counts)), category_counts.index, rotation=45, 
           fontproperties=font, fontsize=18)
plt.yticks(fontsize=18)
plt.tight_layout()
plt.show()

# 输出统计摘要
print("\n=== Index Performance Test Summary ===")
print("\n1. Top 5 Indexes with Best Performance Improvement：")
print(df1.nlargest(5, 'performance_improvement')[['table_name', 'index_name', 'performance_improvement']])
print("\n2. Top 5 Indexes with Greatest Query Time Improvement：")
time_improvement = df1['time_without_index'] - df1['time_with_index']
print(df1.nlargest(5, time_improvement)[['table_name', 'index_name', 'time_without_index', 'time_with_index']])