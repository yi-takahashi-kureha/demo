<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class TopPageController extends Controller
{
    /**
     * トップページを表示します。
     */
    public function index()
    {
        // 'top' という名前のビュー(HTMLファイル)を画面に表示する
        return view('top');
    }
}
