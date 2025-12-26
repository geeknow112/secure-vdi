# Secure VDI

短期セキュリティ調査・脅威分析用の完全隔離AWS WorkSpaces環境を自動構築・削除するプロジェクト

## 🎯 特徴

- **完全隔離**: 本番環境から分離されたVPC
- **自動構築**: Terraformによるワンクリック展開
- **自動削除**: 調査完了後の完全クリーンアップ
- **セキュリティ**: 多層防御とログ監視
- **柔軟な期間設定**: 必要な期間のみ稼働

## 🏗️ アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                    Isolated VPC                            │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │  Public Subnet  │    │        Private Subnet           │ │
│  │                 │    │                                 │ │
│  │  ┌───────────┐  │    │  ┌─────────────────────────────┐│ │
│  │  │NAT Gateway│  │    │  │      AWS WorkSpaces        ││ │
│  │  └───────────┘  │    │  │   (Encrypted Storage)      ││ │
│  └─────────────────┘    │  └─────────────────────────────┘│ │
│                         └─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 クイックスタート

### 前提条件

- AWS CLI設定済み
- Terraform 1.0以上
- 適切なAWS権限

### 1. 環境構築

```bash
git clone https://github.com/geeknow112/secure-vdi
cd secure-vdi
./scripts/deploy.sh
```

### 2. 調査実行

- WorkSpaces接続情報を確認
- セキュリティ調査業務実行
- ログ・証跡の記録

### 3. 環境削除

```bash
./scripts/cleanup.sh
```

## ⚙️ 設定

### 環境変数

```bash
export AWS_PROFILE=your-profile
export CLEANUP_HOURS=72          # 自動削除までの時間
export ANALYST_USERNAME=analyst  # WorkSpacesユーザー名
```

### terraform.tfvars

```hcl
aws_region = "ap-northeast-1"
admin_ips  = ["YOUR.IP.ADDRESS/32"]
directory_password = "SecurePassword123!"
```

## 💰 コスト効率

- **従量課金**: 使用時間分のみ課金
- **自動削除**: 不要な課金を防止
- **リソース最適化**: 必要最小限の構成

### 想定コスト（参考）

| リソース | 時間単価 | 日単価 |
|----------|----------|--------|
| WorkSpaces Performance | $1.75 | $42 |
| NAT Gateway | $0.045 | $1.08 |
| VPC・その他 | $0.02 | $0.48 |
| **合計** | **$1.82** | **$43.56** |

## 🔒 セキュリティ機能

### ネットワーク分離
- 専用VPC（10.100.0.0/16）
- プライベートサブネット配置
- NAT Gateway経由のアウトバウンド通信のみ

### アクセス制御
- IP制限（管理者IPのみ）
- MFA必須設定
- セッション時間制限

### 暗号化
- EBS暗号化（Root・User Volume）
- 転送データ暗号化
- KMS管理キー使用

### 監査・ログ
- CloudTrail全API記録
- VPC Flow Logs
- WorkSpaces接続ログ

## 📋 使用例

### セキュリティ調査
- マルウェア解析
- 脅威インテリジェンス収集
- インシデント対応

### ペネトレーションテスト
- 隔離環境でのテスト実行
- ツール検証
- 概念実証

### コンプライアンス
- セキュリティ監査
- 証拠保全
- フォレンジック調査

## 🛠️ カスタマイズ

### WorkSpacesスペック変更

```hcl
# terraform/modules/workspaces/variables.tf
variable "workspace_bundle" {
  default = "wsb-bh8rsxt14"  # Performance
  # wsb-clj85qzj1 # Value
  # wsb-3t36q0xfc # Standard
  # wsb-1pzkp0bx4 # PowerPro
}
```

### セキュリティグループ調整

```hcl
# 特定ポートの追加
resource "aws_security_group_rule" "custom_port" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = var.admin_ips
  security_group_id = aws_security_group.workspaces_sg.id
}
```

## 🚨 注意事項

### セキュリティ
- 管理者IP制限を必ず設定
- 強力なディレクトリパスワード使用
- 定期的なログ確認

### コスト管理
- 自動削除設定の確認
- 不要なスナップショット削除
- リソース使用量監視

### コンプライアンス
- ログの適切な保管
- データ保護規制の遵守
- インシデント報告手順の確立

## 📚 ドキュメント

- [アーキテクチャ詳細](docs/architecture.md)
- [セキュリティガイドライン](docs/security-guidelines.md)
- [トラブルシューティング](docs/troubleshooting.md)

## 🤝 コントリビューション

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照

## ⚠️ 免責事項

このプロジェクトは教育・研究目的で提供されています。使用に際しては、適用される法律・規制を遵守し、適切なセキュリティ対策を講じてください。