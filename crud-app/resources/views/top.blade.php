@extends('layouts.app')

@section('content')
<div class="row">
    {{-- 左側のメインコンテンツエリア --}}
    <div class="col-md-8">
        <h1>トップページ</h1>
        <p>ここにお知らせやメインコンテンツが表示されます。</p>
    </div>

    {{-- 右側のサイドバー --}}
    <div class="col-md-4">
        {{-- プロフィールカード --}}
        <div class="card mb-4">
            <div class="card-body text-center">
                <i class="bi bi-person-circle" style="font-size: 4rem;"></i>
                <h5 class="card-title mt-2">名前</h5>
                <p class="card-text">所属: ○○部</p>
                <p class="card-text">資格: 基本情報技術者</p>
                <p class="card-text">勉強時間: 100時間</p>
                <a href="#" class="btn btn-primary w-100">My page →</a>
            </div>
        </div>

        {{-- アクションボタン --}}
        <div class="d-grid gap-3">
            <a href="#" class="btn btn-info">日報投稿</a>
            <a href="#" class="btn btn-warning">✨来社ボタン✨</a>
            <a href="#" class="btn btn-success">ナレッジ投稿</a>
        </div>
    </div>
</div>
@endsection
