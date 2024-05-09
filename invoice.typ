// SPDX-FileCopyrightText: 2024 Philipp Klein <philipptheklein@gmail.com>
// SPDX-FileCopyrightText: 2023 Kerstin Humm <kerstin@erictapen.name>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#import "tablex.typ": gridx, hlinex

#set text(lang: "de", region: "DE")

#let details = toml("invoice.toml")

#set page(
  paper: "a4",
  margin: (x: 20%, y: 20%, top: 20%, bottom: 20%),
)

// Typst can't format numbers yet, so we use this from here:
// https://github.com/typst/typst/issues/180#issuecomment-1627451769
#let format_currency(number, precision: 2, decimal_delim: ",", thousands_delim: ".") = {
  let integer = str(calc.floor(number))
  if precision <= 0 {
    return integer
  }

  let value = str(calc.round(number, digits: precision))
  let from_dot = decimal_delim + if value == integer {
    precision * "0"
  } else {
    let precision_diff = integer.len() + precision + decimal_delim.len() - value.len()
    value.slice(integer.len() + 1) + precision_diff * "0"
  }

  let cursor = 3
  while integer.len() > cursor {
    integer = integer.slice(0, integer.len() - cursor) + thousands_delim + integer.slice(integer.len() - cursor, integer.len())
    cursor += thousands_delim.len() + 3
  }
  integer + from_dot
}

#set text(number-type: "old-style")

#smallcaps[
    *#details.author.name* •
    #details.author.street •
    #details.author.zip #details.author.city
  ]

#v(1em)

#[
  #set par(leading: 0.40em)
  #set text(size: 1.2em)
  #details.recipient.name \
  #details.recipient.street \
  #details.recipient.zip
  #details.recipient.city
]

#v(4em)

#[
  #set align(right)
  #details.author.city, #details.date
]

#heading[
    Rechnung \##details.invoice-nr
  ]

#let items = details.items.enumerate().map(
  ((id, item)) => (
    [#str(id + 1).],
    [#item.description],
    [#format_currency(item.price)€],
  )).flatten()

#let total = details.items.map((item) => item.at("price")).sum()

#[
  #set text(number-type: "lining")
  #gridx(
    columns: (auto, 10fr, auto),
    align: ((column, row) => if column == 1 { left } else { right }),
    hlinex(stroke: (thickness: 0.5pt)),
    [*Pos.*],
    [*Beschreibung*],
    [*Preis*],
    hlinex(),
    ..items,
    hlinex(),
    [],
    [
      #set align(end)
      Summe:
    ],
    [#format_currency((1.0 - details.vat) * total)€],
    hlinex(start: 2),
    [],
    [
      #set text(number-type: "old-style")
      #set align(end)
      #str(details.vat * 100)% Mehrwertsteuer:
    ],
    [#format_currency(details.vat * total)€],
    hlinex(start: 2),
    [],
    [
      #set align(end)
      *Gesamt:*
    ],
    [*#format_currency(total)€*],
    hlinex(start: 2),
  )
]

#v(3em)

#[
  #set text(size: 0.8em)
  Vielen Dank für die Zusammenarbeit. Die Rechnungssumme überweisen Sie bitte innerhalb von 14 Tagen ohne Abzug auf mein unten genanntes Konto unter Nennung der
  Rechnungsnummer.

  Gemäß § 19 UStG wird keine Umsatzsteuer berechnet.
]

#v(1em)

#[
  #set par(leading: 0.40em)
  #set text(number-type: "lining")
  Kontoinhaberin: #details.bank_account.name \
  Kreditinstitut: #details.bank_account.bank \
  IBAN: *#details.bank_account.iban* \
  BIC: #details.bank_account.bic
]

Steuernummer: #details.author.tax_nr

#v(1em)

Mit freundlichen Grüßen,

#v(1em)

#details.author.name
