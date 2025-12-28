### 概要

- Windows と Linux のどちらも必要なため、仮想マシン単位で異なる環境が必要

  - GitLab はコンテナ Linux を使う
  - GitLab Runner が使う Runner では Windows が必要

- Hyper-V を使う。単純な好み。
- GUI 操作は面倒かつ標準化しにくいため、PSS を書いた。
